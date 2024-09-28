{
  "name": "{{ .Config.Name }}",
  "devDependencies": {
{{- range $key, $value := (stencil.Arg "packageJsonDeps") }}
    "{{ $key }}": "{{ $value }}",
{{- end }}
    "semantic-release": "23.0.8"
  },
  "dependencies": {
    "@semantic-release/exec": "6.0.3",
    "@semantic-release/git": "10.0.1"
  }
}
