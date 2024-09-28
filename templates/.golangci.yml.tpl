{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- end -}}
# yaml-language-server: $schema=https://json.schemastore.org/golangci-lint
# Linter settings
linters-settings:
  depguard:
    rules:
      main:
        deny:
          - pkg: github.com/go-logr/logr
            desc: Use the pkg/log logging package
          - pkg: github.com/sirupsen/logrus
            desc: Use the pkg/log logging package
          - pkg: log
            desc: Use the pkg/log logging package
  errcheck:
    check-blank: true
  govet:
    enable-all: true
    disable:
      - fieldalignment
    settings:
      shadow:
        strict: true
  gocyclo:
    min-complexity: 25
  dupl:
    threshold: 100
  goconst:
    min-len: 3
    min-occurrences: 3
  lll:
    line-length: 140
  gocritic:
    enabled-tags:
      - diagnostic
      - experimental
      - opinionated
      - performance
      - style
    disabled-checks:
      - whyNoLint # Doesn't seem to work properly
  funlen:
    lines: 500
    statements: 50

linters:
  # Inverted configuration with enable-all and disable is not scalable during updates of golangci-lint.
  disable-all: true
  enable:
    - bodyclose
    - copyloopvar
    - depguard
    - dogsled
    - errcheck
    - errorlint
    - exhaustive # Checks exhaustiveness of enum switch statements.
    - funlen
    - gochecknoinits
    - goconst
    - gocritic
    - gocyclo
    - gofmt
    - goimports
    - revive
    - gosec
    - gosimple
    - govet
    - ineffassign
    - lll
    # - misspell        # The reason we're disabling this right now is because it uses 1/2 of the memory of the run.
    - nakedret
    - staticcheck
    - typecheck
    - unconvert
    - unparam
    - unused
    - whitespace

issues:
  exclude:
    # We allow error shadowing
    - 'declaration of "err" shadows declaration at'
    - "var-naming: don't use an underscore in package name"

  # Excluding configuration per-path, per-linter, per-text and per-source
  exclude-rules:
    # Exclude some linters from running on tests files.
    - path: _test\.go
      linters:
        - gocyclo
        - errcheck
        - gosec
        - funlen
        - gochecknoglobals # Globals in test files are tolerated.
        - goconst # Repeated consts in test files are tolerated.
    # This rule is buggy and breaks on our `///Block` lines.  Disable for now.
    - linters:
        - gocritic
      text: "commentFormatting: put a space"
    # This rule incorrectly flags nil references after assert.Assert(t, x != nil)
    - path: _test\.go
      text: "SA5011"
      linters:
        - staticcheck
    - linters:
        - lll
      source: "^//go:generate "

output:
  formats:
    - format: colored-line-number
  sort-results: true
