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

jobs:
  build-and-test:
    name: Build and Test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
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
          rm stencil_0.9.0_linux_amd64.tar.gz
      - name: Build Test repo
        shell: bash
        run: mise run buildtest

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
