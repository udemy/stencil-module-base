name: Conventional Commit Title Checker

on:
  pull_request:
    types:
      - opened
      - reopened
      - edited
      - synchronize

jobs:
  lint:
    name: Conventional Commit Title Checker
    runs-on: ubuntu-latest
    permissions:
      statuses: write
    steps:
      - name: Conventional Commit Title Checker
        uses: aslafy-z/conventional-pr-title-action@2ce59b07f86bd51b521dd088f0acfb0d7fdac55e
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
