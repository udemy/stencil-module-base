[tools]
nodejs = "22"
yarn = "1.22.22"

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
description = 'Build the Test templates'
dir = "tests"
run = """
#!/usr/bin/env bash
for dir in ./*/ ; do
    (cd "$dir" && stencil);
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
