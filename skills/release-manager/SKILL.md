---
name: release-manager
description: Execute end-to-end release workflow. Handles semantic versioning, changelog verification, version bumps, git tags, GitHub Releases, and main-to-prod merge per dual-branch architecture.
disable-model-invocation: true
context: fork
agent: general-purpose
argument-hint: [version-or-auto]
allowed-tools: Bash(git *), Bash(gh *), Bash(npm *), Bash(jq *), Read, Grep, Glob
---

# Release Manager

## Pre-fetched State

### Current Version
!`cat package.json 2>/dev/null | jq -r '.version // empty' || cat pyproject.toml 2>/dev/null | grep '^version' | head -1 || echo "No version file found"`

### Unreleased Changelog
!`sed -n '/## \[Unreleased\]/,/## \[/p' CHANGELOG.md 2>/dev/null | head -30 || echo "No CHANGELOG.md or no Unreleased section"`

### Commits Since Last Tag
!`git log $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~20)..HEAD --oneline 2>/dev/null || echo "No tags found"`

### Branch Status
!`echo "Branch: $(git branch --show-current)" && echo "Clean: $(git status --porcelain | wc -l | tr -d ' ') uncommitted files" && echo "Remote: $(git rev-list HEAD...origin/$(git branch --show-current) --count 2>/dev/null || echo 'no tracking') commits ahead/behind"`

### Existing Tags
!`git tag --sort=-v:refname | head -10 2>/dev/null || echo "No tags"`

---

## Release Workflow

### 1. Pre-Flight Checks
- Verify on `main` branch
- Verify clean working directory (no uncommitted changes)
- Verify all tests pass
- Verify CHANGELOG.md has an `[Unreleased]` section with content

### 2. Determine Version
If $ARGUMENTS is "auto", determine from commit messages:
- Any `feat:` commit → minor bump
- Any `fix:` commit only → patch bump
- Any `BREAKING CHANGE` or `!:` → major bump

If $ARGUMENTS specifies a version (e.g., "1.2.0"), use that.

### 3. Version Bump
Update version in all relevant files:
```bash
# package.json
npm version $VERSION --no-git-tag-version

# pyproject.toml
sed -i.bak "s/^version = .*/version = \"$VERSION\"/" pyproject.toml
```

### 4. Finalize Changelog
Replace `[Unreleased]` with `[$VERSION] - YYYY-MM-DD` and add a new empty `[Unreleased]` section above.

### 5. Commit and Tag
```bash
git add -A
git commit -m "release: v$VERSION"
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin main --tags
```

### 6. Create GitHub Release
```bash
gh release create "v$VERSION" \
  --title "v$VERSION" \
  --notes "$(changelog_content)"
```

### 7. Production Merge
```bash
git checkout prod
git merge main
git push origin prod
git checkout main
```

### 8. Post-Release Verification
- Confirm tag exists on remote
- Confirm GitHub Release published
- Confirm prod branch updated
- Return release URL

## Rules
- Never release from a dirty working directory
- Never release without tests passing
- Never skip the changelog
- Always tag before pushing
- Always return to `main` branch after prod merge
