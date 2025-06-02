{
  "name": "{{ .Config.Name }}",
{{- if (stencil.Arg "packageJsonScripts") }}
  "scripts": {
{{- $len := len (stencil.Arg "packageJsonScripts") }}
{{- range $key, $value := (stencil.Arg "packageJsonScripts") }}
  {{- $len = (add $len -1) }}
  {{- if ne 0 $len }}
    "{{ $key }}": {{ $value | printf "%q" }},
  {{- else }}
    "{{ $key }}": {{ $value | printf "%q" }}
  {{- end }}
{{- end }}
  },
{{- end }}
  "devDependencies": {
{{- range $key, $value := (stencil.Arg "packageJsonDeps") }}
    "{{ $key }}": "{{ $value }}",
{{- end }}
    "semantic-release": "24.2.5"
  },
  "dependencies": {
    "@semantic-release/exec": "7.1.0",
    "@semantic-release/git": "10.0.1"
  }
}
