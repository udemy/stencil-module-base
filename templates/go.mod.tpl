{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- end -}}
module github.com/udemy/{{ .Config.Name }}

go 1.23.1

// <<Stencil::Block(requires)>>
{{- if empty (trim (file.Block "requires")) }}
require (
	github.com/pkg/errors v0.9.1
	github.com/stretchr/testify v1.9.0
	go.rgst.io/stencil v0.10.2
)
{{- else }}
{{ file.Block "requires" }}
{{- end }}
// <</Stencil::Block>>
