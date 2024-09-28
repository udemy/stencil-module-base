{
  "recommendations": [
    "editorconfig.editorconfig",
    "esbenp.prettier-vscode",
    "timonwong.shellcheck",
    "redhat.vscode-yaml",
    "foxundermoon.shell-format",
    "vsls-contrib.codetour",
{{- if stencil.Arg "nativeModule" }}
    "golang.go",
{{- end }}
    "tamasfe.even-better-toml"
  ]
}
