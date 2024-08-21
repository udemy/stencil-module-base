name: build-release
on:
  push:
    branches:
      - 'main'
    paths:
      - 'templates/**'
      - 'manifest.yaml'
      - 'stencil.yaml'

permissions: write-all

env:
  GH_ROLE_ARN: arn:aws:iam::576384128468:role/GithubActions-github-actions-services-repos-Role

jobs:
  build-and-test:
    name: Build and Test
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: {{ "${{ env.GH_ROLE_ARN }}" }}
          aws-region: 'us-east-1'
      - name: Get Github Secrets from Secrets manager
        uses: aws-actions/aws-secretsmanager-get-secrets@v2
        with:
          secret-ids: |
            CODEOWNER_CHECK_TOKEN_FOR_PROTO
      - name: Checkout
        uses: actions/checkout@v4
        env:
          GITHUB_TOKEN: {{ "${{ env.CODEOWNER_CHECK_TOKEN_FOR_PROTO }}" }}
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
          GITHUB_TOKEN: {{ "${{ env.CODEOWNER_CHECK_TOKEN_FOR_PROTO }}" }}

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
