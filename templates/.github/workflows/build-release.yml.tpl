name: build-release
on:
  push:
    branches:
      - 'main'
    paths:
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
          app_id: 407179
          private_key: {{ "${{ env.GITHUB_CODE_UPGRADE_ENGINE_APP_KEY }}" }}
      - name: Checkout
        uses: actions/checkout@v4
        env:
          GITHUB_TOKEN: {{ "${{ steps.generate_token.outputs.token }}" }}
      - name: Install Tool Versions
        uses: jdx/mise-action@052520c41a328779551db19a76697ffa34f3eabc
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
      - name: Install Stencil
        shell: bash
        run: | # install the stencil binary
          wget https://github.com/rgst-io/stencil/releases/download/v0.9.0/stencil_0.9.0_linux_amd64.tar.gz && \
          tar -xvf stencil_0.9.0_linux_amd64.tar.gz && \
          chmod a+x stencil && \
          pwd && \
          rm stencil_0.9.0_linux_amd64.tar.gz && \
          echo $(pwd) >> $GITHUB_PATH
      - name: Build Test repo
        shell: bash
        run: mise run buildtest
        env:
          # Needs this token for getting access to other repos
          GITHUB_TOKEN: {{ "${{ steps.generate_token.outputs.token }}" }}

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
        run: npm ci
      - name: Release
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
        run: npx semantic-release
