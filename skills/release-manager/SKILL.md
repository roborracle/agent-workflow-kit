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
sed -i.bak "s/^version = .*/version = \"$VERSION\"/" pyproject.toml && rm pyproject.toml.bak
```

### 4. Finalize Changelog
Replace `[Unreleased]` with `[$VERSION] - YYYY-MM-DD` and add a new empty `[Unreleased]` section above.

### 5. Commit and Tag
```bash
# Stage only the release files; `git add -A` would sweep in stray files
git add CHANGELOG.md
git add package.json package-lock.json pyproject.toml 2>/dev/null || true
git commit -m "chore(release): v$VERSION"
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin main --follow-tags
```

### 6. Create GitHub Release
```bash
# Extract this version's section from CHANGELOG.md as the release notes
awk -v v="$VERSION" '$0 ~ "^## \\[" v "\\]" {f=1; next} /^## \[/ {f=0} f' CHANGELOG.md > "release-notes-$VERSION.md"
gh release create "v$VERSION" \
  --title "v$VERSION" \
  --notes-file "release-notes-$VERSION.md"
rm "release-notes-$VERSION.md"
```

### 7. Production Promotion
Pushing to `prod` is a deploy: confirm with the user before this step. `main` carries docs, tests, and debug tooling that `prod` must not, so a plain `git merge main` defeats the sanitized-`prod` rule. Promote with the project's documented process (a promotion script, a `.deployignore`, or a release branch that strips dev-only paths). If the project documents none, stop and ask how `prod` is sanitized instead of merging.

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
- Always return to `main` branch after prod promotion
