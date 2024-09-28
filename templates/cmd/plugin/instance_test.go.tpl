{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- else -}}
{{- file.Static -}}
{{- end -}}
package main

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"go.rgst.io/stencil/pkg/extensions/apiv1"
)

func TestGetTeam(t *testing.T) {
	i, err := NewInstance(context.Background())
	assert.NoError(t, err)

	tiRaw, err := i.GetTeamByID(&apiv1.TemplateFunctionExec{Arguments: []any{"platform"}})
	assert.NoError(t, err)
	ti := tiRaw.(models.OwningTeam)

	assert.Equal(t, "platform", *ti.ID)
}

func TestGetInvalidTeam(t *testing.T) {
	i, err := NewInstance(context.Background())
	assert.NoError(t, err)

	_, err = i.GetTeamByID(&apiv1.TemplateFunctionExec{Arguments: []any{"sdfsdfsdfwesd"}})
	assert.Error(t, err)
}
