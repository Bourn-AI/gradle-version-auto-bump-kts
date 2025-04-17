# gradle-version-auto-bump-kts

A GitHub action to find and increment the project version in a Kotlin Gradle build file and create customizable Git tags.

## Version Bumping

Including the following case sensitive 'words' (including hashtag) in the latest commit: 

- '#MAJOR' - will bump the major version by 1
- '#MINOR' - will bump the minor version by 1

In the absence of either, the patch version will always be bumped by 1.

## Tag Creation Options

The action now provides flexible tag creation:

- **Standard Version Tags**: The traditional `vX.Y.Z` format (e.g., `v1.2.3`)
- **Date-Based Tags**: Format with date and version (e.g., `v2025.04.16-1.2.3`)

You can choose which tags to create and customize the date format and separator.

## Requirements

- Requires xx.xx.xx (major.minor.patch) project version pattern.
- Requires project to use Kotlin DSL Gradle build file (build.gradle.kts)
- Requires matching of "version =" for project version to be the first one in the build file.

## Inputs

### `GITHUB_TOKEN`

**Required** The GitHub token.

### `CREATE_VERSION_TAG`

**Optional** Whether to create standard version tag (vX.Y.Z). Default: `true`

### `CREATE_DATE_TAG`

**Optional** Whether to create a date-based tag. Default: `false`

### `PUSH_VERSION_TAG`

**Optional** Whether to push the standard version tag to remote. Default: `true`

### `PUSH_DATE_TAG`

**Optional** Whether to push the date-based tag to remote. Default: `true`

### `DATE_FORMAT`

**Optional** Format for the date portion (using date command format). Default: `%Y.%m.%d`

### `TAG_SEPARATOR`

**Optional** Separator character between date and version. Default: `-`

## Outputs

### `version`

The new version number after bumping.

### `version_tag`

The created version tag (only provided when `CREATE_VERSION_TAG` is `true`).

### `date_tag`

The created date-based tag (only provided when `CREATE_DATE_TAG` is `true`).

## Example usage

Basic usage with only version bumping:

```yaml
- name: Bump Project Version
  uses: username/gradle-version-auto-bump-kts@v1.1
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Create tags but don't push them (for local references only):

```yaml
- name: Bump Project Version
  id: bump-version
  uses: username/gradle-version-auto-bump-kts@v1.1
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    CREATE_VERSION_TAG: true
    CREATE_DATE_TAG: true
    PUSH_VERSION_TAG: false
    PUSH_DATE_TAG: false
```

Create both tags but only push the date-based tag:

```yaml
- name: Bump Project Version
  id: bump-version
  uses: username/gradle-version-auto-bump-kts@v1.1
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    CREATE_VERSION_TAG: true      # Create standard version tag
    PUSH_VERSION_TAG: false       # Don't push standard version tag
    CREATE_DATE_TAG: true         # Create date-based tag
    PUSH_DATE_TAG: true           # Push date-based tag
    
# Use the outputs later in the workflow
- name: Set image tag
  run: |
    echo "IMAGE_TAG=${{ env.ACR_URL }}/${{ env.SERVICE_NAME }}:${{ steps.bump-version.outputs.date_tag }}" >> $GITHUB_ENV
```

Custom date format and separator:

```yaml
- name: Bump Project Version
  id: bump-version
  uses: username/gradle-version-auto-bump-kts@v1.1
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    CREATE_VERSION_TAG: false     # Disable standard version tag
    CREATE_DATE_TAG: true         # Enable date-based tag
    DATE_FORMAT: '%Y%m%d'         # Format without periods (e.g., 20250416)
    TAG_SEPARATOR: '_'            # Use underscore instead of hyphen
```
