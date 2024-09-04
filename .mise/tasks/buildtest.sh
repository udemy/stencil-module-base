#!/usr/bin/env bash
# mise description="Build the Test templates"
cd tests
for dir in ./*/ ; do
    (cd "$dir" && /home/runner/work/stencil-templatemodule/stencil-templatemodule/stencil);
done
