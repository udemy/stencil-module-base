[tools]
nodejs = "22"
pnpm = "latest"
{{- if stencil.Arg "nativeModule" }}
git-cliff = "latest"
golang = "1.24"
golangci-lint = "1.64"
goreleaser = "latest"
"go:gotest.tools/gotestsum" = "v1.12.0"
"go:golang.org/x/tools/cmd/goimports" = "latest"
"go:github.com/thenativeweb/get-next-version" = "latest"
{{- end }}
## <<Stencil::Block(additionalTools)>>
{{ file.Block "additionalTools" }}
## <</Stencil::Block>>

{{- if stencil.Arg "nativeModule" }}

# Native module tasks
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
{{ file.Block "tasks" }}
## <</Stencil::Block>>
