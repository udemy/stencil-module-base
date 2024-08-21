# Default ownership
{{- $teamInfo := stencil.GetGlobal "TeamInfo" | default (dict) }}
* @udemy/{{ index $teamInfo "githubTeam" }}
