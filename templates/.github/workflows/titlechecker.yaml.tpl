name: Conventional Commit Title Checker

on:
  pull_request:
    types:
      - opened
      - reopened
      - edited
      - synchronize
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
  lint:
    name: Conventional Commit Title Checker
    runs-on: {{ stencil.Arg "buildAndTestRunner" | default "ubuntu-latest" }}
    permissions:
      statuses: write
    steps:
      - name: Conventional Commit Title Checker
        uses: aslafy-z/conventional-pr-title-action@2ce59b07f86bd51b521dd088f0acfb0d7fdac55e
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
