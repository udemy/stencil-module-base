# stencil-templatemodule

This is a stencil template module for making it easy to make stencil template modules.  Much meta, wow.

## Manifest Arguments

In the `arguments` section of the `manifest.yaml` file, you can specify the following options:

| Option               | Default         | Description                                                    |
| -------------------- | --------------- | -------------------------------------------------------------- |
| `description`        | Required        | Friendly-but-short description string for the frontend app     |
| `owner`              | Required        | Pod or Portfolio ID for the owner of the frontend app          |
| `buildAndTestRunner` | `ubuntu-latest` | The github actions runner to use for the build and test CI job |
