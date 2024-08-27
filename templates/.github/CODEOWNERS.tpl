# See https://help.github.com/articles/about-codeowners/
# Default ownership -- owning team owns everything by default
{{- $teamInfo := stencil.GetGlobal "TeamInfo" | default (dict) }}
* @udemy/{{ index $teamInfo "githubTeam" }}
