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
      ## Add additional linker flags for the plugin build here
      ## Example: -X main.version={{ .Version }}
      {{ file.Block "pluginLdflags" }}
      ## <</Stencil::Block>>
    env:
      - CGO_ENABLED=0
    goarch:
      - amd64
      - arm64
      ## <<Stencil::Block(pluginExtraArch)>>
      ## Add additional architectures to build for here (e.g., "386", "arm")
      ## Default architectures are amd64 and arm64
      {{ file.Block "pluginExtraArch" }}
      ## <</Stencil::Block>>
    goos:
      - linux
      - darwin
      - windows
      ## <<Stencil::Block(pluginExtraOS)>>
      ## Add additional operating systems to build for here (e.g., "freebsd", "openbsd")
      ## Default operating systems are linux, darwin, and windows
      {{ file.Block "pluginExtraOS" }}
      ## <</Stencil::Block>>
    ignore:
      - goos: windows
        goarch: arm
    mod_timestamp: "{{ "{{ .CommitTimestamp }}" }}"
checksum:
  name_template: "checksums.txt"
snapshot:
  version_template: "{{ "{{ incpatch .Version }}-next" }}"
changelog:
  use: git
release:
  prerelease: "auto"
  footer: |-
    **Full Changelog**: https://github.com/{{ stencil.Arg "githubOrg" }}/{{ .Config.Name }}/compare/{{ "{{ .PreviousTag }}...{{ .Tag }}" }}
