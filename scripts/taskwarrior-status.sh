#!/bin/bash
set -eEo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
HUMANIZE_DATE="$SCRIPT_DIR/humanize-date.sh"

output_status() {
    local state=$1
    local tooltip=$2
    # Escape quotes/backslashes for JSON
    tooltip=$(echo "$tooltip" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"text\":\"\",\"alt\":\"${state}\",\"class\":\"${state}\",\"tooltip\":\"$tooltip\"}"
}

# Get next 10 pending tasks sorted by due date using JSON export for reliable parsing
tasks_json=$(task +PENDING export 2>/dev/null | jq 'sort_by(.due // "9999") | .[0:10]')

# Determine icon state
if task +PENDING due.before:now count 2>/dev/null | grep -q '[1-9]'; then
    state="due"
else
    state="default"
fi

# Build tooltip
tooltip=""
if [ -n "$tasks_json" ] && [ "$tasks_json" != "[]" ]; then
    # Header
    task_count=$(echo "$tasks_json" | jq 'length')
    overdue_count=$(task +PENDING +OVERDUE count 2>/dev/null || echo 0)

    tooltip="<b>📋 Tasks</b> <span size='small'>($task_count pending"
    if [ "$overdue_count" -gt 0 ]; then
        tooltip+=", <span foreground='#ff6b6b'>$overdue_count overdue</span>"
    fi
    tooltip+=")</span>&#10;&#10;"

    # Process each task from JSON - avoid subshell by using process substitution
    while IFS= read -r task; do
        desc=$(echo "$task" | jq -r '.description')
        due=$(echo "$task" | jq -r '.due // empty')
        priority=$(echo "$task" | jq -r '.priority // empty')

        # Get humanized due date
        if [ -n "$due" ]; then
            rel_due=$("$HUMANIZE_DATE" "$due" 2>/dev/null || echo "invalid date")
        else
            rel_due="no due"
        fi

        # Priority indicator
        priority_icon=""
        case "$priority" in
            H) priority_icon="<span foreground='#ff6b6b'>●</span> " ;;
            M) priority_icon="<span foreground='#feca57'>●</span> " ;;
            L) priority_icon="<span foreground='#48dbfb'>●</span> " ;;
        esac

        # Style based on status
        if [[ "$rel_due" =~ "ago" ]] || [[ "$rel_due" = "yesterday" ]]; then
            # Overdue - red and bold
            tooltip+="${priority_icon}<span foreground='#ff6b6b'><b>$desc</b></span>"
            tooltip+=" <span size='small' foreground='#ff6b6b'>⏰ $rel_due</span>&#10;"
        elif [[ "$rel_due" = "today"* ]]; then
            # Due today - orange/yellow
            tooltip+="${priority_icon}<span foreground='#feca57'><b>$desc</b></span>"
            tooltip+=" <span size='small' foreground='#feca57'>📅 $rel_due</span>&#10;"
        elif [[ "$rel_due" = "tomorrow"* ]]; then
            # Due tomorrow - light emphasis
            tooltip+="${priority_icon}<b>$desc</b>"
            tooltip+=" <span size='small' foreground='#48dbfb'>📅 $rel_due</span>&#10;"
        else
            # Future or no due date
            tooltip+="${priority_icon}$desc"
            tooltip+=" <span size='small' alpha='60%'>$rel_due</span>&#10;"
        fi
    done < <(echo "$tasks_json" | jq -c '.[]')
else
    tooltip="<b>📋 Tasks</b>&#10;&#10;<span alpha='60%'>No pending tasks</span>"
fi

# Output JSON
output_status "$state" "$tooltip"
