{{- if not (stencil.Arg "templateModule") -}}
{{- file.Delete -}}
{{- else -}}
{{- file.Once -}}
{{- end -}}
# yaml-language-server: $schema=https://stencil.rgst.io/static/stencil.jsonschema.json
name: {{ .Config.Name }}-test
arguments:
  templateModule: true
modules:
  - name: github.com/{{ stencil.Arg "githubOrg" }}/{{ .Config.Name }}
replacements:
  github.com/{{ stencil.Arg "githubOrg" }}/{{ .Config.Name }}: ../../
