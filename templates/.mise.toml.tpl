[tools]
nodejs = "22"
yarn = "1.22.22"

[tasks.cleantest]
description = "Clean the test directory"
dir = "test"
run = ["git clean -xdf"]
