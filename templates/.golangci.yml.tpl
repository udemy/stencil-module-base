{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- end -}}
# yaml-language-server: $schema=https://json.schemastore.org/golangci-lint
# Linter settings
version: "2"
output:
  formats:
    text:
      path: stdout
linters:
  # Inverted configuration with enable-all and disable is not scalable during updates of golangci-lint.
  default: none
  enable:
    - bodyclose
    - copyloopvar
    - depguard
    - dogsled
    - errcheck
    - errorlint
    - exhaustive
    - funlen
    - gochecknoinits
    - goconst
    - gocritic
    - gocyclo
    - gosec
    - govet
    - ineffassign
    - lll
    - nakedret
    - revive
    - staticcheck
    - unconvert
    - unparam
    - unused
    - whitespace
  settings:
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
    dupl:
      threshold: 100
    errcheck:
      check-blank: true
    funlen:
      lines: 500
      statements: 50
    goconst:
      min-len: 3
      min-occurrences: 3
    gocritic:
      disabled-checks:
        - whyNoLint # Doesn't seem to work properly
      enabled-tags:
        - diagnostic
        - experimental
        - opinionated
        - performance
        - style
    gocyclo:
      min-complexity: 25
    govet:
      disable:
        - fieldalignment
      enable-all: true
      settings:
        shadow:
          strict: true
    lll:
      line-length: 140
  exclusions:
    generated: lax
    presets:
      - comments
      - common-false-positives
      - legacy
      - std-error-handling
    rules:
      # Exclude some linters from running on tests files.
      - linters:
          - errcheck
          - funlen
          - gochecknoglobals # Globals in test files are tolerated.
          - goconst # Repeated consts in test files are tolerated.
          - gocyclo
          - gosec
        path: _test\.go
      # This rule is buggy and breaks on our `///Block` lines.  Disable for now.
      - linters:
          - gocritic
        text: 'commentFormatting: put a space'
      # This rule incorrectly flags nil references after assert.Assert(t, x != nil)
      - linters:
          - staticcheck
        path: _test\.go
        text: SA5011
      - linters:
          - lll
        source: '^//go:generate '
      # We allow error shadowing
      - path: (.+)\.go$
        text: declaration of "err" shadows declaration at
      - path: (.+)\.go$
        text: 'var-naming: don''t use an underscore in package name'
    paths:
      - third_party$
      - builtin$
      - examples$
formatters:
  enable:
    - gofmt
    - goimports
  exclusions:
    generated: lax
    paths:
      - third_party$
      - builtin$
      - examples$
