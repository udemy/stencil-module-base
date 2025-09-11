{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- else -}}
{{- file.Static -}}
{{- end -}}
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"

	"github.com/pkg/errors"
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
)

// _ ensures that Instance fits the apiv1.Implementation interface.
var _ apiv1.Implementation = &Instance{}

// Instance contains a [apiv1.Implementation] satisfying plugin.
type Instance struct {
	ctx context.Context
}

// NewInstance creates a new [Instance].
//nolint: unparam // Why: Save error for future potential usage
func NewInstance(ctx context.Context) (*Instance, error) {
	return &Instance{
		ctx: ctx,
	}, nil
}

// GetConfig returns a [apiv1.Config] for the [Instance].
func (*Instance) GetConfig() (*apiv1.Config, error) {
	return &apiv1.Config{}, nil
}

func (*Instance) GetTemplateFunctions() ([]*apiv1.TemplateFunction, error) {
	return []*apiv1.TemplateFunction{
		{
			Name:              "DoSomething",
			NumberOfArguments: 1,
		},
	}, nil
}

func (i *Instance) ExecuteTemplateFunction(tfe *apiv1.TemplateFunctionExec) (any, error) {
	switch tfe.Name { //nolint:gocritic
	case "DoSomething":
		return i.DoSomething(tfe)
	}

	return nil, fmt.Errorf("unknown template function: %s", tfe.Name)
}

// DoSomething does something, we promise
func (i *Instance) DoSomething(t *apiv1.TemplateFunctionExec) (any, error) {
	someArg, ok := t.Arguments[0].(string)
	if !ok {
		return nil, fmt.Errorf("expected string argument, got %T", t.Arguments[0])
	}
	if someArg == "error" {
		return nil, fmt.Errorf("error")
	}
	fmt.Printf("Passed valid arg: %s\n", someArg)

	return nil, nil
}
