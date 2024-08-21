name: github.com/udemy/{{ .Config.Name }}
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
modules:
  - name: github.com/udemy/eng-team-management
