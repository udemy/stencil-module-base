name: build-release
on:
  push:
    branches:
      - 'main'
    paths:
      - '.github/workflows/build-release.yml'
      - 'templates/**'
      - 'manifest.yaml'
      - 'stencil.yaml'

env:
  GH_ROLE_ARN: arn:aws:iam::602046956384:role/GithubActions-code-upgrade-engine-app-Role

jobs:
  build-and-test:
    name: Build and Test
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
      actions: read
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::602046956384:role/GithubActions-code-upgrade-engine-app-Role
          aws-region: 'us-east-1'
      - name: Get Github Secrets from Secrets manager
        uses: aws-actions/aws-secretsmanager-get-secrets@v2
        with:
          secret-ids: |
            GITHUB_CODE_UPGRADE_ENGINE_APP_KEY
      - name: Generate a token
        id: generate_token
        uses: actions/create-github-app-token@v1
        with:
          app-id: 407179
          private-key: {{ "${{ env.GITHUB_CODE_UPGRADE_ENGINE_APP_KEY }}" }}
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
        run: | # install the stencil binary
          mkdir {{ "${{ runner.temp }}/stencil" }}
          cd {{ "${{ runner.temp }}/stencil" }}
          wget https://github.com/rgst-io/stencil/releases/download/v0.9.0/stencil_0.9.0_linux_amd64.tar.gz && \
          tar -xvf stencil_0.9.0_linux_amd64.tar.gz && \
          chmod a+x stencil && \
          rm stencil_0.9.0_linux_amd64.tar.gz && \
          echo $(pwd) >> $GITHUB_PATH
      ## <<Stencil::Block(buildtestauth)>>
{{ file.Block "buildtestauth" }}
      ## <</Stencil::Block>>
      - name: Build Test repo
        run: mise run buildtest
        env:
          GITHUB_TOKEN: {{ "${{ steps.generate_token.outputs.token }}" }}
      ## <<Stencil::Block(buildteststeps)>>
{{ file.Block "arguments" }}
      ## <</Stencil::Block>>

  build-release:
    name: Build and Release
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
        env:
          GH_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Install Semantic-Release
        run: yarn install
      - name: Release
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
        run: npx semantic-release
