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
      - '.github/workflows/build-release.yml'
      - 'templates/**'
      - 'tests/**'
      - 'manifest.yaml'
      - 'stencil.yaml'

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
      - name: Install Tool Versions
        uses: jdx/mise-action@052520c41a328779551db19a76697ffa34f3eabc
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Install Stencil
        uses: rgst-io/stencil-action@34abb7be7ca3847f233bd9c38f1da71b30556c35
        with:
          github-token: {{ "${{ github.token }}" }}
          version: 'latest'
      ## <<Stencil::Block(buildtestauth)>>
{{ file.Block "buildtestauth" }}
      ## <</Stencil::Block>>
      - name: Build Test repo
        run: mise run buildtest
        env:
          GITHUB_TOKEN: {{ "${{ steps.generate_token.outputs.token }}" }}
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
          token: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Install Tool Versions
        uses: jdx/mise-action@052520c41a328779551db19a76697ffa34f3eabc
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Install Semantic-Release
        run: yarn install
      - name: Release
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
        run: npx semantic-release
