# yaml-language-server: $schema=https://raw.githubusercontent.com/rgst-io/stencil/v0.9.0/schemas/stencil.jsonschema.json
name: {{ .Config.Name }}-test
arguments:
  description: Test folder for validating changes to {{ .Config.Name }}
  owner: {{ stencil.Arg "owner" }}
  # <<Stencil::Block(arguments)>>
{{ file.Block "arguments" }}
  # <</Stencil::arguments>>
modules:
  - name: github.com/udemy/{{ .Config.Name }}
replacements:
  github.com/udemy/{{ .Config.Name }}: ../
