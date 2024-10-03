{{- if not (stencil.Arg "githubOwner") -}}
{{- file.Delete -}}
{{- end -}}
# See https://help.github.com/articles/about-codeowners/
# Default ownership -- owning team owns everything by default
* {{ stencil.Arg "githubOwner" }}
