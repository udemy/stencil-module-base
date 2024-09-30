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

env:
  GH_ROLE_ARN: arn:aws:iam::602046956384:role/GithubActions-github-actions-services-repos-Role

jobs:
  build-and-test:
    name: Build and Test
    runs-on: {{ stencil.Arg "buildAndTestRunner" | default "ubuntu-latest" }}
    permissions:
      id-token: write
      contents: read
      actions: read
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::602046956384:role/GithubActions-github-actions-services-repos-Role
          aws-region: 'us-east-1'
      - name: Get Github Secrets from Secrets manager
        uses: aws-actions/aws-secretsmanager-get-secrets@v2
        with:
          secret-ids: |
            GITHUB_CUE_APP_KEY
      ## <<Stencil::Block(getMoreCiSecrets)>>
{{ file.Block "getMoreCiSecrets" }}
      ## <</Stencil::Block>>
      - name: Generate a token
        id: generate_token
        uses: actions/create-github-app-token@v1
        with:
          app-id: 407179
          private-key: {{ "${{ env.GITHUB_CUE_APP_KEY }}" }}
          owner: udemy
      - name: Set git Credentials
        run: |
          git config --global "url.https://udemy:{{ "${{ steps.generate_token.outputs.token }}" }}@github.com/.insteadOf" https://github.com/
      - name: Checkout
        uses: actions/checkout@v4
        with:
          persist-credentials: false
          token: {{ "${{ steps.generate_token.outputs.token }}" }}
          # These two required for builds to successfully amend commits
          ref: {{ "${{ github.head_ref }}" }}
          fetch-depth: 2
      - name: Install Tool Versions
        uses: jdx/mise-action@f8dfbcc150159126838e44b882bf34bd98fd90f3
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Install Stencil
        uses: rgst-io/stencil-action@34abb7be7ca3847f233bd9c38f1da71b30556c35
        with:
          github-token: {{ "${{ github.token }}" }}
          version: 'latest'
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
        uses: golangci/golangci-lint-action@v4
        with:
          version: latest
          # We already use setup-go's pkg cache and actions/cache's build cache, so don't double-up
          skip-pkg-cache: true
          skip-build-cache: true
          args: --timeout=6m
      - name: Build Go binary
        run: mise run build
      - name: Run Go Tests
        run: go run gotest.tools/gotestsum@v1.11.0
        ## <<Stencil::Block(gotestvars)>>
{{ file.Block "gotestvars" }}
        ## <</Stencil::Block>>
{{- end }}
{{- if stencil.Arg "templateModule" }}
      ## <<Stencil::Block(buildtestauth)>>
{{ file.Block "buildtestauth" }}
      ## <</Stencil::Block>>
      - name: Build Test repo
        run: mise run buildtest
        env:
          GITHUB_TOKEN: {{ "${{ steps.generate_token.outputs.token }}" }}
          ## <<Stencil::Block(buildTestEnvVars)>>
{{ file.Block "buildTestEnvVars" }}
          ## <</Stencil::Block>>
      - name: Run Tests
        run: mise run runtest
        env:
          GITHUB_TOKEN: {{ "${{ steps.generate_token.outputs.token }}" }}
          ## <<Stencil::Block(runTestEnvVars)>>
{{ file.Block "runTestEnvVars" }}
          ## <</Stencil::Block>>
      ## <<Stencil::Block(buildteststeps)>>
{{ file.Block "arguments" }}
      ## <</Stencil::Block>>
{{- end }}

  build-release:
    name: Build and Release
    if: {{ "${{ github.ref == 'refs/heads/main' }}" }} # Only run on main branch commits
    needs: build-and-test
    runs-on: ubuntu-latest
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
        uses: jdx/mise-action@f8dfbcc150159126838e44b882bf34bd98fd90f3
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
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
          args: release --release-notes CHANGELOG.md --clean
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
          ## <<Stencil::Block(goreleaserEnvVars)>>
{{ file.Block "goreleaserEnvVars" }}
          ## <</Stencil::Block>>
{{- else }}
      - name: Install Semantic-Release
        run: yarn install
      - name: Release
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
        run: npx semantic-release
{{- end }}

  ## <<Stencil::Block(extraActions)>>
{{ file.Block "extraActions" }}
  ## <</Stencil::Block>>
