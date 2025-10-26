#!/bin/bash
# Checks Taskwarrior for due or overdue tasks and notifies if any found.

set -eEo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
HUMANIZE_DATE="$SCRIPT_DIR/humanize-date.sh"
TASKRC=${TASKRC:-$HOME/.taskrc}

# Get due/overdue tasks and tasks due in next 5 minutes
overdue_tasks=$(task +PENDING +OVERDUE export 2>/dev/null)
due_soon_tasks=$(task +PENDING due.before:now+5min export 2>/dev/null | jq '[.[] | select(.status == "pending")]')

# Combine and deduplicate
all_due_tasks=$(echo "$overdue_tasks$due_soon_tasks" | jq -s 'add | unique_by(.uuid)' 2>/dev/null)

if [ -n "$all_due_tasks" ] && [ "$all_due_tasks" != "[]" ] && [ "$all_due_tasks" != "null" ]; then
    count=$(echo "$all_due_tasks" | jq 'length')
    overdue_count=$(echo "$overdue_tasks" | jq 'length' 2>/dev/null || echo 0)

    # Build message
    if [ "$overdue_count" -gt 0 ]; then
        msg="⚠️  $overdue_count overdue, $((count - overdue_count)) due soon"
    else
        msg="📌 $count task(s) due soon"
    fi

    # Build task list with humanized times
    list=""
    while IFS= read -r task; do
        desc=$(echo "$task" | jq -r '.description')
        due=$(echo "$task" | jq -r '.due // empty')

        if [ -n "$due" ]; then
            rel_due=$("$HUMANIZE_DATE" "$due" 2>/dev/null || echo "")
            if [ -n "$rel_due" ]; then
                list+="• $desc ($rel_due)\n"
            else
                list+="• $desc\n"
            fi
        else
            list+="• $desc\n"
        fi
    done < <(echo "$all_due_tasks" | jq -c '.[] | select(. != null)' | head -n5)

    # Send notification
    notify-send -u critical -t 10000 "⏰ Taskwarrior Reminder" "$msg\n\n$list"
    paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null &

    echo "due" > /tmp/taskwarrior_due_state
else
    echo "none" > /tmp/taskwarrior_due_state
fi
