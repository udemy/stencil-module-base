name: github.com/udemy/{{ .Config.Name }}
postRunCommand:
  ## <<Stencil::Block(postruncommands)>>
{{ file.Block "postruncommands" }}
  ## <</Stencil::Block>>
arguments:
  description:
    required: true
    description: Friendly-but-short description string for the template module
    schema:
      type: string
  owner:
    required: true
    description: Team ID (see eng-team-management repo) for the owner of the template module
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
