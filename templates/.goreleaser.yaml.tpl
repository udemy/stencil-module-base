{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- end -}}
# yaml-language-server: $schema=https://goreleaser.com/static/schema.json
version: 2
project_name: {{ .Config.Name }}
report_sizes: true
metadata:
  mod_timestamp: "{{ "{{ .CommitTimestamp }}" }}"
builds:
  - main: ./cmd/plugin
    flags:
      - -trimpath
    ldflags:
      - -s
      - -w
      ## <<Stencil::Block(pluginLdflags)>>
{{ file.Block "pluginLdflags" }}
      ## <</Stencil::Block>>
    env:
      - CGO_ENABLED=0
    goarch:
      - amd64
      - arm64
      ## <<Stencil::Block(pluginExtraArch)>>
{{ file.Block "pluginExtraArch" }}
      ## <</Stencil::Block>>
    goos:
      - linux
      - darwin
      - windows
      ## <<Stencil::Block(pluginExtraOS)>>
{{ file.Block "pluginExtraOS" }}
      ## <</Stencil::Block>>
    ignore:
      - goos: windows
        goarch: arm
    mod_timestamp: "{{ "{{ .CommitTimestamp }}" }}"
checksum:
  name_template: "checksums.txt"
snapshot:
  name_template: "{{ "{{ incpatch .Version }}-next" }}"
changelog:
  use: git
release:
  prerelease: "auto"
  footer: |-
    {{ "**Full Changelog**: https://github.com/udemy/eng-team-management/compare/{{ .PreviousTag }}...{{ .Tag }}" }}
