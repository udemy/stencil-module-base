#!/usr/bin/env bash
# mise description="Build the Test templates"
cd tests
for dir in ./*/ ; do
    (cd "$dir" && /home/runner/work/{{ .Config.Name }}/{{ .Config.Name }}/stencil);
done
