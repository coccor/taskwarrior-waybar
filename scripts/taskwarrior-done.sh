#!/bin/bash
set -eEo pipefail

TASK="/usr/bin/task"
NOTIFY="/usr/bin/notify-send"

# Get all pending tasks with their descriptions
tasks=$($TASK +PENDING rc.verbose=nothing rc.report.next.columns:id,description rc.report.next.labels:ID,Description next 2>/dev/null)

# Check if there are any tasks
if [ -z "$tasks" ] || ! echo "$tasks" | grep -q '[0-9]'; then
    $NOTIFY "✅ No pending tasks"
    echo "No pending tasks"
    read -p "Press Enter to exit..."
    exit 0
fi

# Display tasks
echo "=== Pending Tasks ==="
echo "$tasks"
echo ""

# Get task IDs (skip empty lines and header if present)
task_ids=$($TASK +PENDING rc.verbose=nothing rc.report.next.columns:id rc.report.next.labels:ID next 2>/dev/null | grep -E '^[[:space:]]*[0-9]+' | awk '{print $1}')

# Count tasks
task_count=$(echo "$task_ids" | wc -l)

if [ "$task_count" -eq 0 ]; then
    $NOTIFY "✅ No pending tasks"
    echo "No pending tasks"
    read -p "Press Enter to exit..."
    exit 0
fi

# Prompt user for task ID
echo -n "Enter task ID to mark done (or press Enter for most urgent): "
read chosen_id

# If no ID entered, pick the first task (most urgent)
if [ -z "$chosen_id" ]; then
    chosen_id=$(echo "$task_ids" | head -n1)
fi

# Validate task ID exists
if ! echo "$task_ids" | grep -q "^${chosen_id}$"; then
    echo "❌ Invalid task ID: $chosen_id"
    read -p "Press Enter to exit..."
    exit 1
fi

# Get description for notification
desc=$($TASK _get "${chosen_id}.description" 2>/dev/null)

# Mark done
$TASK done "$chosen_id" >/dev/null 2>&1

# Notify
$NOTIFY "✅ Task completed" "$desc"
echo "✅ Task completed: $desc"

read -p "Press Enter to exit..."
