name: build-release
on:
  pull_request:
    types:
      - opened
      - reopened
      - edited
      - synchronize
  push:
    branches:
      - 'main'
    paths:
      - 'stencil.yaml'
      - 'manifest.yaml'
      - '.mise.toml'
      - '.github/workflows/build-release.yml'
{{- if stencil.Arg "templateModule" }}
      - 'templates/**'
      - 'tests/**'
{{- end }}
{{- if stencil.Arg "nativeModule" }}
      - 'go.mod'
      - 'go.sum'
      - '.goreleaser.yaml'
      - 'cmd/**'
      - 'pkg/**'
      - 'internal/**'
{{- end }}

jobs:
  build-and-test:
    name: Build and Test
    runs-on: {{ stencil.Arg "buildAndTestRunner" | default "ubuntu-latest" }}
    permissions:
      id-token: write
      contents: write
      actions: read
    steps:
      ## <<Stencil::Block(getMoreCiSecrets)>>
      ## Add additional CI secret configuration steps here
      ## Use this to configure authentication or secrets needed for the build/test process
      ## Example: - name: Configure AWS, uses: aws-actions/configure-aws-credentials@v2
      {{ file.Block "getMoreCiSecrets" }}
      ## <</Stencil::Block>>
      - name: Checkout
        uses: actions/checkout@v4
        with:
          persist-credentials: false
          # These two required for builds to successfully amend commits
          ref: {{ "${{ github.head_ref }}" }}
          fetch-depth: 2
      - name: Install Tool Versions
        uses: jdx/mise-action@5ac50f778e26fac95da98d50503682459e86d566
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Install once
        uses: jaxxstorm/action-install-gh-release@6096f2a2bbfee498ced520b6922ac2c06e990ed2
        with:
          repo: jaredallard/once
{{- if stencil.Arg "nativeModule" }}
      - name: Get Go directories
        id: go
        run: |
          echo "cache_dir=$(go env GOCACHE)" >> "$GITHUB_OUTPUT"
          echo "mod_cache_dir=$(go env GOMODCACHE)" >> "$GITHUB_OUTPUT"
      - uses: actions/cache@v4
        with:
          path: {{ "${{ steps.go.outputs.cache_dir }}" }}
          key: {{ "${{ github.workflow }}-${{ runner.os }}-go-build-cache-${{ hashFiles('**/go.sum') }}" }}
      - uses: actions/cache@v4
        with:
          path: {{ "${{ steps.go.outputs.mod_cache_dir }}" }}
          key: {{ "${{ github.workflow }}-${{ runner.os }}-go-mod-cache-${{ hashFiles('go.sum') }}" }}
      - name: Lint
        uses: golangci/golangci-lint-action@v8
        with:
          version: v2.4
          args: --timeout=10m
      - name: Build Go binary
        run: mise run build
      - name: Run Go Tests
        run: go run gotest.tools/gotestsum@latest
        ## <<Stencil::Block(gotestvars)>>
        ## Add environment variables for Go tests here
        ## Example: env: TEST_DB_URL: ${{ secrets.TEST_DB_URL }}
        {{ file.Block "gotestvars" }}
        ## <</Stencil::Block>>
{{- end }}
{{- if stencil.Arg "templateModule" }}
      - name: Install Stencil
        uses: rgst-io/stencil-action@34abb7be7ca3847f233bd9c38f1da71b30556c35
        with:
          github-token: {{ "${{ github.token }}" }}
          version: 'latest'
      ## <<Stencil::Block(buildtestauth)>>
      ## Add authentication configuration steps for build/test here
      ## Use this to set up authentication needed before building or testing
      ## Example: - name: Authenticate, uses: some-auth-action@v1
      {{ file.Block "buildtestauth" }}
      ## <</Stencil::Block>>
      - name: Build Test repo
        run: mise run buildtest
        # Fill in env: -> GITHUB_TOKEN here if you need a custom token to read module dependencies
        ## <<Stencil::Block(buildTestEnvVars)>>
        ## Add environment variables for the Build Test repo step here
        ## Example: env: GITHUB_TOKEN: ${{ secrets.CUSTOM_TOKEN }}
        {{ file.Block "buildTestEnvVars" }}
        ## <</Stencil::Block>>
      - name: Run Tests
        run: mise run runtest
        # Fill in env: -> GITHUB_TOKEN here if you need a custom token to read module dependencies
        ## <<Stencil::Block(runTestEnvVars)>>
        ## Add environment variables for the Run Tests step here
        ## Example: env: GITHUB_TOKEN: ${{ secrets.CUSTOM_TOKEN }}
        {{ file.Block "runTestEnvVars" }}
        ## <</Stencil::Block>>
      - name: Install JS Deps
        run: pnpm install
      - name: Update README.md if needed
        run: mise run gentable
        env:
          # Fill in GH_TOKEN env with a different token here if you need a custom token to read module dependencies
          ## <<Stencil::Block(readmeUpdateGhToken)>>
          ## Override the GitHub token used for README updates here
          ## Default: GH_TOKEN: ${{ github.token }}
          ## Example: GH_TOKEN: ${{ secrets.CUSTOM_GH_TOKEN }}
{{- if empty (file.Block "readmeUpdateGhToken") }}
          GH_TOKEN: {{ "${{ github.token }}" }}
{{- else }}
{{ file.Block "readmeUpdateGhToken" }}
{{- end }}
          ## <</Stencil::Block>>
      - name: Commit back any changes
        uses: stefanzweifel/git-auto-commit-action@e348103e9026cc0eee72ae06630dbe30c8bf7a79 #v5
        with:
          commit_message: Update README.md manifest options table
      ## <<Stencil::Block(buildteststeps)>>
      ## Add additional build/test steps here
      ## These steps will run after the standard build and test steps
      ## Example: - name: Custom Step, run: echo "Custom action"
      {{ file.Block "buildteststeps" }}
      ## <</Stencil::Block>>
{{- end }}

  build-release:
    name: Build and Release
    if: {{ "${{ github.ref == 'refs/heads/main' }}" }} # Only run on main branch commits
    needs: build-and-test
    runs-on: {{ stencil.Arg "buildAndTestRunner" | default "ubuntu-latest" }}
    permissions: write-all
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          fetch-tags: true
          token: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Set git User
        run: |
          git config user.name github-actions
          git config user.email github-actions@github.com
      - name: Install Tool Versions
        uses: jdx/mise-action@5ac50f778e26fac95da98d50503682459e86d566
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Install once
        uses: jaxxstorm/action-install-gh-release@6096f2a2bbfee498ced520b6922ac2c06e990ed2
        with:
          repo: jaredallard/once
{{- if stencil.Arg "nativeModule" }}
      - name: Get Go directories
        id: go
        run: |
          echo "cache_dir=$(go env GOCACHE)" >> "$GITHUB_OUTPUT"
          echo "mod_cache_dir=$(go env GOMODCACHE)" >> "$GITHUB_OUTPUT"
      - uses: actions/cache@v4
        with:
          path: {{ "${{ steps.go.outputs.cache_dir }}" }}
          key: {{ "${{ github.workflow }}-${{ runner.os }}-go-build-cache-${{ hashFiles('**/go.sum') }}" }}
      - uses: actions/cache@v4
        with:
          path: {{ "${{ steps.go.outputs.mod_cache_dir }}" }}
          key: {{ "${{ github.workflow }}-${{ runner.os }}-go-mod-cache-${{ hashFiles('go.sum') }}" }}
      - name: Retrieve goreleaser version
        run: |-
          echo "version=$(mise current goreleaser)" >> "$GITHUB_OUTPUT"
        id: goreleaser
      - name: Get next version
        id: next_version
        run: |-
          get-next-version --target github-action
      - name: Create Tag
        if: {{ "${{ steps.next_version.outputs.hasNextVersion == 'true' }}" }}
        run: |-
          git tag -a {{ "\"v${{ steps.next_version.outputs.version }}\" -m \"Release v${{ steps.next_version.outputs.version }}\"" }}
      - name: Generate CHANGELOG
        if: {{ "${{ steps.next_version.outputs.hasNextVersion == 'true' }}" }}
        run: |-
          mise run changelog
      - name: Create release artifacts and Github Release
        if: {{ "${{ steps.next_version.outputs.hasNextVersion == 'true' }}" }}
        uses: goreleaser/goreleaser-action@v6
        with:
          distribution: goreleaser
          version: {{ "v${{ steps.goreleaser.outputs.version }}" }}
          args: release --release-notes tempchangelog.md --clean
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
          ## <<Stencil::Block(goreleaserEnvVars)>>
          ## Add environment variables for goreleaser here
          ## Example: CUSTOM_VAR: ${{ secrets.CUSTOM_VAR }}
          {{ file.Block "goreleaserEnvVars" }}
          ## <</Stencil::Block>>
{{- else }}
      - name: Install JS Deps
        run: pnpm install
      - name: Release
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
        run: npx semantic-release
{{- end }}

  ## <<Stencil::Block(extraActions)>>
  ## Add additional GitHub Actions jobs here
  ## These jobs will run alongside the build-and-test and build-release jobs
  ## Example: my-custom-job: name: Custom Job, runs-on: ubuntu-latest, steps: [...]
  {{ file.Block "extraActions" }}
  ## <</Stencil::Block>>
