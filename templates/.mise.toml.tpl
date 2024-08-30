[tools]
nodejs = "22"
yarn = "1.22.22"

[tasks.cleantest]
description = "Clean the test directory"
dir = "test"
run = ["git clean -xdf"]

[tasks.buildtest]
description = "Build the test template module to validate the templates"
dir = "test"
depends = ["cleantest"]
run = [
  "stencil",
  "mise install",
  ## <<Stencil::Block(teststeps)>>
{{ file.Block "teststeps" }}
  ## <</Stencil::Block>>
]
