[tools]
nodejs = "lts"
pnpm = "latest"
{{- if stencil.Arg "nativeModule" }}
git-cliff = "latest"
golang = "1.25"
golangci-lint = "2.4"
goreleaser = "latest"
"go:gotest.tools/gotestsum" = "latest"
"go:golang.org/x/tools/cmd/goimports" = "latest"
"go:github.com/thenativeweb/get-next-version" = "latest"
{{- end }}
## <<Stencil::Block(additionalTools)>>
## Add additional tool versions here (e.g., "rust = '1.75'", "python = '3.11'")
## These will be installed via mise alongside the default tools
{{ file.Block "additionalTools" }}
## <</Stencil::Block>>

{{- if stencil.Arg "nativeModule" }}

# Native module tasks
[tasks.checks]
description = "Run all pre-commit checks"
depends = ["build", "fmt", "lint", "test"]

[tasks.build]
description = "Build a binary for the current platform/architecture"
run = "go build -trimpath -o ./bin/ -v ./cmd/..."

[tasks.changelog]
description = "Generate a changelog for the current version"
outputs = ["tempchangelog.md"]
run = ["git-cliff --latest --output tempchangelog.md"]

[tasks.fmt]
alias = "format"
description = "Format code"
run = ["go mod tidy", "gofmt -s -w .", "goimports -w ."]

[tasks.lint]
description = "Run linters"
run = "golangci-lint run"

[tasks.next-version]
description = """Get the version number that would be released if a release was ran right now.
Pass --rc to get the next release candidate version.
"""
run = ["./.github/scripts/get-next-version.sh"]

[tasks.test]
description = "Run tests"
run = "gotestsum"
{{- end }}
{{- if stencil.Arg "templateModule" }}

# Template module tasks
[tasks.cleantest]
description = "Helper to clean the test directory"
dir = "tests"
run = """
#!/usr/bin/env bash
for dir in ./*/ ; do
    (cd "$dir" && git clean -xdf);
done
"""

[tasks.buildtest]
description = 'Build the Test projects'
dir = "tests"
run = """
#!/usr/bin/env bash
for dir in ./*/ ; do
    (cd "$dir" && echo "Building the project $dir" && stencil) || exit 1;
done
"""

[tasks.runtest]
description = 'Run the tests'
dir = "tests"
## <<Stencil::Block(runTests)>>
## Customize the test runner configuration here
## This block allows you to override the default test execution command
## You can add environment variables, change the test directory, or modify the test command
{{- if (empty (file.Block "runTests")) }}
env = {ENV_VAR_NAME = 'hooray'} # env vars for the script
run = """
#!/usr/bin/env bash
echo "Tests are running"
"""
{{- else }}
{{ file.Block "runTests" }}
{{- end }}
## <</Stencil::Block>>
{{- end }}

[tasks.gentable]
description = 'Generate the README.md table of arguments'
run = "node scripts/yamltotable.js"

## <<Stencil::Block(tasks)>>
## Add custom mise tasks here (e.g., [tasks.mytask] description = "...", run = "...")
## These tasks will be available via 'mise run <task-name>'
{{ file.Block "tasks" }}
## <</Stencil::Block>>
