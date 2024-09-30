# stencil-module-base

This is a stencil module for making it easy to make stencil modules.  Much meta, wow.

Stencil modules can be a native and/or template module.  A native module is one that contains native golang code.  A template module is one that contains templated code.  If you are looking for a guide on how to make your own stencil modules, check out the [stencil documentation](https://stencil.rgst.io/).

## Manifest Arguments

In the `arguments` section of the `manifest.yaml` file, you can specify the following options:

| Option               | Default         | Description                                                    |
| -------------------- | --------------- | -------------------------------------------------------------- |
| `description`        | Required        | Friendly-but-short description string for the frontend app     |
| `owner`              | Required        | Pod or Portfolio ID for the owner of the frontend app          |
| `nativeModule`       | `false`         | Does this module include native module golang code             |
| `templateModule`     | `false`         | Does this module include templated code                        |
| `buildAndTestRunner` | `ubuntu-latest` | The github actions runner to use for the build and test CI job |
