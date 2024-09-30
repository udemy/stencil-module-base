{{- if not (stencil.Arg "templateModule") -}}
{{- file.Delete -}}
{{- else -}}
{{- file.Once -}}
{{- end -}}
# yaml-language-server: $schema=https://stencil.rgst.io/static/stencil.jsonschema.json
name: {{ .Config.Name }}-test
arguments:
  description: Test folder for validating changes to {{ .Config.Name }}
  owner: {{ stencil.Arg "owner"}}
  ## <<Stencil::Block(arguments)>>
{{ file.Block "arguments" }}
  ## <</Stencil::Block>>
modules:
  - name: github.com/udemy/{{ .Config.Name }}
replacements:
  github.com/udemy/{{ .Config.Name }}: ../../
