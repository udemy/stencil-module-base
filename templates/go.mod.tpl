{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- end -}}
module github.com/{{ stencil.Arg "githubOrg" }}/{{ .Config.Name }}

go 1.25

// Add extra Go module dependencies here. If empty, default require block is used; if set, it replaces the default.
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
