#!/bin/bash
# Exit on any error
set -e

# Extract the current version from build.gradle.kts
CURRENT_VERSION=$(grep 'version =' build.gradle.kts | sed -E 's/.*"(.*)"/\1/')

# Parse the version into major, minor, and patch
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Check the commit message to decide version bump type
COMMIT_MESSAGE=$(git log -1 --pretty=%B)
if [[ $COMMIT_MESSAGE == *"#MAJOR"* ]]; then
  MAJOR=$((MAJOR + 1))
  MINOR=0
  PATCH=0
elif [[ $COMMIT_MESSAGE == *"#MINOR"* ]]; then
  MINOR=$((MINOR + 1))
  PATCH=0
else
  PATCH=$((PATCH + 1))
fi

# Construct the new version
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update the version in build.gradle.kts
sed -i.bak -E "s/version = \".*\"/version = \"$NEW_VERSION\"/" build.gradle.kts

# Configure git to use the GitHub App identity
git config --global user.name 'version-auto-bump[bot]'
git config --global user.email '206832292+version-auto-bump[bot]@users.noreply.github.com'

# Commit the version bump
git commit -am "Bump version to $NEW_VERSION [skip ci]"

# Get the date format and separator from inputs
DATE_FORMAT="${DATE_FORMAT:-%Y.%m.%d}"
TAG_SEPARATOR="${TAG_SEPARATOR:--}"

# Initialize tags arrays
CREATED_TAGS=()
TAGS_TO_PUSH=()

# Create standard version tag if enabled
if [[ "$CREATE_VERSION_TAG" == "true" ]]; then
  VERSION_TAG="v$NEW_VERSION"
  git tag -a "$VERSION_TAG" -m "Release version $NEW_VERSION"
  CREATED_TAGS+=("$VERSION_TAG")
  echo "version_tag=${VERSION_TAG}" >> $GITHUB_OUTPUT
  echo "Created version tag: ${VERSION_TAG}"

  # Add to push list if push is enabled
  if [[ "$PUSH_VERSION_TAG" == "true" ]]; then
    TAGS_TO_PUSH+=("$VERSION_TAG")
  fi
fi

# Create date-based tag if enabled
if [[ "$CREATE_DATE_TAG" == "true" ]]; then
  # Generate a tag with date format
  DATE_VERSION=$(date +"$DATE_FORMAT")
  DATE_TAG="v${DATE_VERSION}${TAG_SEPARATOR}${NEW_VERSION}"

  # Create the date-based tag
  git tag -a "$DATE_TAG" -m "Release version $NEW_VERSION on $(date +'%Y-%m-%d')"
  CREATED_TAGS+=("$DATE_TAG")

  # Output the date tag for the action
  echo "date_tag=${DATE_TAG}" >> $GITHUB_OUTPUT
  echo "Created date-based tag: ${DATE_TAG}"

  # Add to push list if push is enabled
  if [[ "$PUSH_DATE_TAG" == "true" ]]; then
    TAGS_TO_PUSH+=("$DATE_TAG")
  fi
fi

# Output the version for the action
echo "version=${NEW_VERSION}" >> $GITHUB_OUTPUT

# Push the commits
git push "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" HEAD:main

# Push the requested tags if any need to be pushed
if [ ${#TAGS_TO_PUSH[@]} -gt 0 ]; then
  echo "Pushing tags: ${TAGS_TO_PUSH[*]}"
  for tag in "${TAGS_TO_PUSH[@]}"; do
    echo "Pushing tag: $tag"
    git push "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" "$tag"
  done
else
  if [ ${#CREATED_TAGS[@]} -gt 0 ]; then
    echo "Tags created but not pushed: ${CREATED_TAGS[*]}"
  fi
fi
