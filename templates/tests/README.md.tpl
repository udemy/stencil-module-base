{{ file.Static -}}

For every test case that you have, regarding your stencil templates, you should have a corresponding directory which contains its own stencil.yaml in the tests directory.  

This is a good practice to ensure that your templates are working as expected. 

The CI pipeline will execute all the tests in the tests directory and will fail if any of them fail.
