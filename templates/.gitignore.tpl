# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib
__debug_bin*

# Editor files
*.swp
*~
\#*\#
.idea/*
TAGS
*.sublime-project
*.sublime-workspace
.\#*
.dir-locals.el

# Test binary, build with "go test -c"
*.test

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# Log files
*.log

# Releases and other binaries
bin/
dist/

# Don't. Commit. Vendor. Or other package manager dep directories
node_modules
vendor

# macOS
.DS_Store

# Currently a build artifact for native modules
tempchangelog.md

# Ignore literally everything under the tests directory (except the README) -- specifically include the dir and stencil.yaml file
# for each test case in the ignores block below
tests/*
!tests/README.md

{{ if stencil.Exists "tests" -}}
{{ range $entry := stencil.ReadDir "tests" -}}
{{ if $entry.IsDir -}}
!tests/{{ $entry.Name }}
tests/{{ $entry.Name }}/*
!tests/{{ $entry.Name }}/stencil.yaml
{{ end -}}
{{ end -}}
{{ end -}}
## <<Stencil::Block(ignores)>>
{{ file.Block "ignores" }}
## <</Stencil::Block>>
