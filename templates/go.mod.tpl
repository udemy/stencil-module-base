{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- end -}}
module github.com/{{ stencil.Arg "githubOrg" }}/{{ .Config.Name }}

go 1.24

// <<Stencil::Block(requires)>>
{{- if empty (trim (file.Block "requires")) }}
require (
	github.com/pkg/errors v0.9.1
	github.com/stretchr/testify v1.10.0
	go.rgst.io/stencil/v2 v2.0.1
)
{{- else }}
{{ file.Block "requires" }}
{{- end }}
// <</Stencil::Block>>
