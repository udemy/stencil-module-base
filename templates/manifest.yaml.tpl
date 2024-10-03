name: github.com/{{ stencil.Arg "githubOrg" }}/{{ .Config.Name }}
{{- if and (stencil.Arg "nativeModule") (stencil.Arg "templateModule") }}
type: templates,extension
{{- else if stencil.Arg "nativeModule" }}
type: extension
{{- else if stencil.Arg "templateModule" }}
type: templates
{{- else }}
{{- fail "Either templateModule or nativeModule must be true" }}
{{- end }}
arguments:
  ## <<Stencil::Block(arguments)>>
{{ file.Block "arguments" }}
  ## <</Stencil::Block>>
modules:
  ## <<Stencil::Block(modules)>>
{{ file.Block "modules" }}
  ## <</Stencil::Block>>
## <<Stencil::Block(extra)>>
{{ file.Block "extra" }}
## <</Stencil::Block>>
