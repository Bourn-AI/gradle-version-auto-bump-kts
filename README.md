# gradle-version-auto-bump-kts

A little github action to find and increment the project version in a kotlin gradle build file. 

Including the following case sensitive 'words' (including hashtag) in the latest commit: 

- '#MAJOR' - will bump the major version by 1
- '#MINOR' - will bump the minor version by 1

In the absence of either, the patch version will always be bumped by 1.

Requires xx.xx.xx (major.minor.patch) project version pattern.

Requires project to use kotlin dsl gradle build file (build.gradle.kts)

Requires matching of "vesion =" for project version to be the first one in the build file. 

## Inputs

### `GITHUB_TOKEN`

**Required** The GitHub token.

## Example usage
```
  - name: Bump Project Version
    uses: gregjmarshall/gradle-version-auto-bump-kts@v1
    with:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
