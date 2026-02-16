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
  # Add custom Stencil module arguments here. Used in templates when generating projects.
  ## <<Stencil::Block(arguments)>>
{{ file.Block "arguments" }}
  ## <</Stencil::Block>>
modules:
  # Add additional Stencil modules to include. Loaded and available during project generation.
  ## <<Stencil::Block(modules)>>
{{ file.Block "modules" }}
  ## <</Stencil::Block>>
# Add extra manifest config here (e.g. postRunCommand, hooks).
## <<Stencil::Block(extra)>>
{{ file.Block "extra" }}
## <</Stencil::Block>>
