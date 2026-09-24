---
name: init-project
description: "Initialize a new project with Claude Code .claude/ directory, CLAUDE.md, framework-specific rules, and standard configuration (set up project, init, bootstrap, new project)."
disable-model-invocation: true
---

# Initialize Project Configuration

Set up this project's `.claude/` directory with standard configuration, framework-specific rules, and optional PRD scaffolding.

## 1. Check Current State
```bash
ls -la .claude/ 2>/dev/null || echo "No .claude directory found"
ls package.json composer.json requirements.txt pyproject.toml Cargo.toml 2>/dev/null || echo "No package manifest found"
```

## 2. Create Directory Structure
```bash
mkdir -p .claude/skills .claude/rules
```

## 3. Detect Stack and Install Framework Pack

Check which stack this project uses and copy the matching framework pack from `~/.claude/skills/init-project/packs/` into `.claude/rules/`.

### Detection logic:
- `package.json` with `next` dependency → **Next.js** → copy `packs/nextjs.md` to `.claude/rules/nextjs.md`
- `composer.json` or `wp-content/` exists → **WordPress** → copy `packs/wordpress.md` to `.claude/rules/wordpress.md`
- `requirements.txt` or `pyproject.toml` exists → **Python** → copy `packs/python.md` to `.claude/rules/python.md`
- None detected → ask the user which stack, or skip framework pack

```bash
# Example for Next.js detection:
if [ -f package.json ] && grep -q '"next"' package.json 2>/dev/null; then
  cp ~/.claude/skills/init-project/packs/nextjs.md .claude/rules/nextjs.md
  echo "Installed Next.js framework pack"
fi
```

Only install ONE framework pack per project.

## 4. Create Project CLAUDE.md
Create `.claude/CLAUDE.md` from the template in `~/.claude/rules/documentation-protocol.md` § "Project `CLAUDE.md` template": a thin reference layer holding only this project's deltas (paths, context, stack, overrides, pointers to deeper docs).

## 5. Add to .gitignore
Ensure `.claude/settings.local.json` is in `.gitignore`.

## 6. Project-Level Rules
Only add rules for things the global rules don't already cover. List `~/.claude/rules/` to see the current set.

## 7. Offer PRD Scaffolding
Ask the user if they want a PRD template created. If yes:
```bash
mkdir -p docs/strategy
cp ~/.claude/skills/product-strategist/prd-template.md docs/strategy/prd.md
echo "Created docs/strategy/prd.md — fill in project-specific details"
```

## 8. Check Existing Config
If `.claude/agents/` or `.claude/commands/` exist, list what's in them and leave them in place. Project subagents and commands are current Claude Code features, and removing either is a deletion the user confirms first.

## 9. Verify
```bash
echo "=== Project Config ==="
cat .claude/CLAUDE.md
echo ""
echo "=== Project Rules ==="
ls .claude/rules/ 2>/dev/null || echo "(using globals only)"
echo ""
echo "=== Global Config ==="
echo "Rules:"
ls ~/.claude/rules/
echo "Skills:"
ls ~/.claude/skills/
```

## Do NOT
- Copy global rules into the project (they apply automatically)
- Copy global skills into the project (they're available everywhere)
- Create duplicate skills or duplicate rules
- Install multiple framework packs (one per project)
