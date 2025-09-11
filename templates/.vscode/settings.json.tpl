{
{{- if stencil.Arg "nativeModule" }}
  "go.lintTool": "golangci-lint",
  "go.formatTool": "goimports",
  "go.useLanguageServer": true,
{{- end }}
  "files.trimTrailingWhitespace": true,
  "files.exclude": {
    "**/bin": true,
    "**/.task": true,
    "**/node_modules": true,
  },
  "editor.formatOnSave": true,
  "shellcheck.customArgs": ["-P", "SCRIPTDIR", "-x"],
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[yaml]": {
    "editor.defaultFormatter": "redhat.vscode-yaml"
  }
}
