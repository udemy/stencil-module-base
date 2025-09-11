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
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
)

func TestDoSomething(t *testing.T) {
	i, err := NewInstance(context.Background())
	assert.NoError(t, err)

	ret, err := i.DoSomething(&apiv1.TemplateFunctionExec{Arguments: []any{"arg"}})
	assert.NoError(t, err)
	assert.Nil(t, ret)

	ret, err = i.DoSomething(&apiv1.TemplateFunctionExec{Arguments: []any{"error"}})
	assert.Error(t, err, "error")
	assert.Nil(t, ret)
}
