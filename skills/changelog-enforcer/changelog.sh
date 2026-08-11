#!/bin/bash

# Changelog Generator
# Generates organized, dated changelog files from Git history
# Usage: bash changelog.sh [period]
# Periods: day, week (default), month, year, sprint, or number of days

generate_changelog() {
    local period="${1:-week}"
    local output_dir="changelogs"
    local date_stamp=$(date +"%Y-%m-%d")
    local time_stamp=$(date +"%H-%M-%S")

    mkdir -p "$output_dir"

    case "$period" in
        day|today)
            since="1 day ago"
            period_label="Daily"
            ;;
        week)
            since="7 days ago"
            period_label="Weekly"
            ;;
        month)
            since="30 days ago"
            period_label="Monthly"
            ;;
        year)
            since="365 days ago"
            period_label="Yearly"
            ;;
        sprint)
            since="6 days ago"
            period_label="Sprint"
            ;;
        [0-9]*)
            since="$period days ago"
            period_label="${period}-Day"
            ;;
        *)
            since="7 days ago"
            period_label="Weekly"
            ;;
    esac

    local filename="${output_dir}/CHANGELOG_${period_label}_${date_stamp}_${time_stamp}.md"

    cat > "$filename" << EOF
# Changelog - ${period_label} Report
**Generated**: $(date +"%B %d, %Y at %I:%M %p %Z")
**Branch**: $(git branch --show-current)

---

## Summary Statistics

EOF

    local total_commits=$(git rev-list --count HEAD --since="$since" 2>/dev/null || echo "0")
    local contributors=$(git shortlog -sn --since="$since" 2>/dev/null | wc -l)
    local files_changed=$(git diff --stat $(git rev-list -n 1 --before="$since" HEAD 2>/dev/null) HEAD 2>/dev/null | tail -1)

    cat >> "$filename" << EOF
- **Total Commits**: $total_commits
- **Contributors**: $contributors
- **Files Changed**: ${files_changed:-"N/A"}

---

## Highlights

EOF

    local highlights=$(git log --since="$since" --pretty=format:"- %s" --grep="BREAKING\|MAJOR\|CRITICAL\|feat\!:\|fix\!:" -i 2>/dev/null | head -5)
    if [ -n "$highlights" ]; then
        echo "$highlights" >> "$filename"
    else
        echo "- No major highlights in this period" >> "$filename"
    fi

    echo "" >> "$filename"
    echo "---" >> "$filename"
    echo "" >> "$filename"

    echo "## Features" >> "$filename"
    git log --since="$since" --pretty=format:"- %s (%h)" --grep="^feat" -i 2>/dev/null | head -10 >> "$filename" || echo "- No new features" >> "$filename"
    echo -e "\n" >> "$filename"

    echo "## Bug Fixes" >> "$filename"
    git log --since="$since" --pretty=format:"- %s (%h)" --grep="^fix" -i 2>/dev/null | head -10 >> "$filename" || echo "- No bug fixes" >> "$filename"
    echo -e "\n" >> "$filename"

    echo "## Documentation" >> "$filename"
    git log --since="$since" --pretty=format:"- %s (%h)" --grep="^docs" -i 2>/dev/null | head -10 >> "$filename" || echo "- No documentation updates" >> "$filename"
    echo -e "\n" >> "$filename"

    echo "## Refactoring" >> "$filename"
    git log --since="$since" --pretty=format:"- %s (%h)" --grep="^refactor" -i 2>/dev/null | head -10 >> "$filename" || echo "- No refactoring" >> "$filename"
    echo -e "\n" >> "$filename"

    echo "## Chores & Maintenance" >> "$filename"
    git log --since="$since" --pretty=format:"- %s (%h)" --grep="^chore" -i 2>/dev/null | head -10 >> "$filename" || echo "- No maintenance tasks" >> "$filename"
    echo -e "\n" >> "$filename"

    echo "---" >> "$filename"
    echo "" >> "$filename"
    echo "## Top Modified Files" >> "$filename"
    echo '```' >> "$filename"
    git diff --stat --name-only $(git rev-list -n 1 --before="$since" HEAD 2>/dev/null) HEAD 2>/dev/null | head -15 >> "$filename"
    echo '```' >> "$filename"

    echo "" >> "$filename"
    echo "---" >> "$filename"

    echo "Changelog generated: $filename"
}

generate_changelog "$@"
