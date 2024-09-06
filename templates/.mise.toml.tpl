[tools]
nodejs = "22"
yarn = "1.22.22"

[tasks.cleantest]
description = "Clean the test directory"
dir = "test"
run = ["git clean -xdf"]

[tasks.buildtest]
description = 'Build the Test templates'
run = """
#!/usr/bin/env bash
cd tests
for dir in ./*/ ; do
    (cd "$dir" && stencil);
done
"""

[tasks.runtest]
description = 'Run the tests'
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
