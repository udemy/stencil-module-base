branches:
  - main
plugins:
  - - "@semantic-release/commit-analyzer"
    - releaseRules:
        - type: revert
          release: patch
        - type: perf
          release: patch
  # This creates fancy release notes in our Github release
  - "@semantic-release/release-notes-generator"
  # Create the Github Release
  - - "@semantic-release/github"
    - successComment: false
      failTitle: false
