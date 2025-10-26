#!/bin/bash
# Read task description and optional due from terminal

echo -n "Task description: "
read desc
[ -z "$desc" ] && exit 0

echo -n "Due (e.g., 5min, 1h, 2d, tomorrow) — optional: "
read due

if [ -n "$due" ]; then
    # If the input looks like a relative time (5min, 1h, 2d, etc.),
    # prepend 'now+' for taskwarrior
    if [[ "$due" =~ ^[0-9]+[smhdwy]+$ ]]; then
        due="now+$due"
    fi
    task add "$desc" due:$due >/dev/null
else
    task add "$desc" >/dev/null
fi

echo "✅ Task added: $desc"
read -p "Press Enter to exit..."
