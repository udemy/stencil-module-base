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
      pull-requests: read
    steps:
      - name: Conventional Commit Title Checker
        uses: amannn/action-semantic-pull-request@0723387faaf9b38adef4775cd42cfd5155ed6017
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
