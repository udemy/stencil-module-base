# This will blow up inside the native extension if the team isn't found
{{ $teamInfo := extensions.Call "github.com/udemy/eng-team-management.GetTeamByID" (stencil.Arg "owner") }}
{{ stencil.SetGlobal "TeamInfo" $teamInfo }}
