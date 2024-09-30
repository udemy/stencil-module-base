name: github.com/udemy/{{ .Config.Name }}
{{- if and (stencil.Arg "nativeModule") (stencil.Arg "templateModule") }}
type: templates,extension
{{- else if stencil.Arg "nativeModule" }}
type: extension
{{- else if stencil.Arg "templateModule" }}
type: templates
{{- else }}
{{- fail "Either templateModule or nativeModule must be true" }}
{{- end }}
dirReplacements:
  ## <<Stencil::Block(dirReplacements)>>
{{ file.Block "dirReplacements" }}
  ## <</Stencil::Block>>
postRunCommand:
  ## <<Stencil::Block(postruncommands)>>
{{ file.Block "postruncommands" }}
  ## <</Stencil::Block>>
arguments:
  description:
    required: true
    description: Friendly-but-short description string for the repository
    schema:
      type: string
  owner:
    required: true
    description: Team ID (see eng-team-management repo) for the owner of the repository
    schema:
      type: string
  ## <<Stencil::Block(arguments)>>
{{ file.Block "arguments" }}
  ## <</Stencil::Block>>
modules:
  - name: github.com/udemy/eng-team-management
  ## <<Stencil::Block(modules)>>
{{ file.Block "modules" }}
  ## <</Stencil::Block>>
## <<Stencil::Block(extra)>>
{{ file.Block "extra" }}
## <</Stencil::Block>>
