# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

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

# Ignore literally everything other than the stencil.yaml file in the tests dir
tests/*
!tests/**/stencil.yaml

## <<Stencil::Block(ignores)>>
{{ file.Block "ignores" }}
## <</Stencil::Block>>
