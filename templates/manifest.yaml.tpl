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
  ## Add custom Stencil module arguments here
  ## These arguments can be used in templates and are passed when generating projects from this module
{{ file.Block "arguments" }}
  ## <</Stencil::Block>>
modules:
  ## <<Stencil::Block(modules)>>
  ## Add additional Stencil modules to include here
  ## These modules will be loaded and their templates will be available during project generation
{{ file.Block "modules" }}
  ## <</Stencil::Block>>
## <<Stencil::Block(extra)>>
## Add extra manifest configuration here (e.g., postRunCommand, hooks, etc.)
## This block allows you to extend the manifest with additional configuration options
{{ file.Block "extra" }}
## <</Stencil::Block>>
