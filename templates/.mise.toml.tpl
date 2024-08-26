[tools]
nodejs = "22"
yarn = "1.22.22"

[tasks.buildtest]
description = "Build the test template module to validate the templates"
dir = "test"
run = [
  "stencil",
  "mise install",
  # <<Stencil::Block(teststeps)>>
{{ file.Block "teststeps" }}
  # <</Stencil::Block>>
]
