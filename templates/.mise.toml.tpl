[tools]
nodejs = "22"
"go:go.rgst.io/stencil/cmd/stencil" = "0.9.0"

[tasks.buildtest]
description = "Build the test template module to validate the templates"
dir = "test"
run = ["stencil", "mise install"]
