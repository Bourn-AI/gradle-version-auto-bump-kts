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
git config --global user.name 'Version Auto Bump App'
git config --global user.email 'version-auto-bump[bot]@users.noreply.github.com'
# Commit the version bump
git commit -am "Bump version to $NEW_VERSION"
# Tag the new version
git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"
# Push the changes and tags using the GitHub App token
git push "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" HEAD:main
