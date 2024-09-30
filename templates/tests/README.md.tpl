{{- if not (stencil.Arg "templateModule") -}}
{{- file.Delete -}}
{{- else -}}
{{ file.Static -}}
{{- end -}}
For every test case that you have, regarding your stencil templates, you should have a corresponding directory which contains its own stencil.yaml in the tests directory.

Make sure to also add each of these tests to the .gitignore file so that you don't commit the test results to the repository.

This is a good practice to ensure that your templates are working as expected.

The CI pipeline will execute all the tests in the tests directory and will fail if any of them fail.
