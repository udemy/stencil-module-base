{{- if not (stencil.Arg "nativeModule") -}}
{{- file.Delete -}}
{{- end -}}
package main

import (
	"context"
	"os"

	"go.rgst.io/stencil/pkg/extensions/apiv1"
	"go.rgst.io/stencil/pkg/slogext"
)

// main starts the native extension
func main() {
	ctx := context.Background()
	log := slogext.New()

	pi, err := NewInstance(ctx)
	if err != nil {
		log.WithError(err).Error("failed to create plugin instance")
		os.Exit(1)
	}

	if err := apiv1.NewExtensionImplementation(pi, log); err != nil {
		log.WithError(err).Error("failed to create extension")
		os.Exit(1)
	}
}
