#!/bin/bash
# humanize-date.sh - Convert dates/timestamps to human-readable relative time
#
# Usage:
#   humanize-date.sh <date_string>
#
# Examples:
#   humanize-date.sh "2025-10-26 21:00:00"
#   humanize-date.sh "20251026T210000Z"
#   humanize-date.sh "2025-10-25"
#
# Output examples:
#   today in 10h22m
#   tomorrow at 14:30
#   yesterday
#   in 3d
#   2d ago

set -eEo pipefail

# Input date/timestamp
input_date="$1"

if [ -z "$input_date" ]; then
    echo "Error: No date provided" >&2
    echo "Usage: $0 <date_string>" >&2
    exit 1
fi

# Convert taskwarrior ISO format (20251026T210000Z) to YYYY-MM-DD HH:MM:SS
parse_date() {
    local date="$1"

    # Check if it's taskwarrior ISO format (ends with Z = UTC)
    if [[ "$date" =~ ^[0-9]{8}T[0-9]{6}Z$ ]]; then
        # Convert to ISO 8601 format that date can parse as UTC
        echo "$date" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)T\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)Z/\1-\2-\3T\4:\5:\6Z/'
    else
        # Assume it's already in a parseable format
        echo "$date"
    fi
}

# Parse input date
parsed_date=$(parse_date "$input_date")
date_seconds=$(date --date="$parsed_date" +%s 2>/dev/null || { echo "Error: Invalid date format" >&2; exit 1; })

# Get current time and date info
now_seconds=$(date +%s)
diff=$((date_seconds - now_seconds))

# Get date components
date_only=$(date --date="$parsed_date" +%Y-%m-%d 2>/dev/null)
today=$(date +%Y-%m-%d)
tomorrow=$(date --date="tomorrow" +%Y-%m-%d)
yesterday=$(date --date="yesterday" +%Y-%m-%d)

# Determine relative time description
if [ "$date_only" = "$today" ]; then
    # For today's tasks, show time remaining
    if [ "$diff" -gt 0 ]; then
        hours=$((diff / 3600))
        minutes=$(((diff % 3600) / 60))
        if [ "$hours" -gt 0 ]; then
            echo "today in ${hours}h${minutes}m"
        else
            echo "today in ${minutes}m"
        fi
    else
        # Overdue today
        diff=$(( -diff ))
        hours=$((diff / 3600))
        minutes=$(((diff % 3600) / 60))
        if [ "$hours" -gt 0 ]; then
            echo "today ${hours}h${minutes}m ago"
        else
            echo "today ${minutes}m ago"
        fi
    fi
elif [ "$date_only" = "$tomorrow" ]; then
    # Show time for tomorrow
    hours=$((diff / 3600))
    remaining_hours=$((hours % 24))
    if [ "$remaining_hours" -gt 0 ]; then
        echo "tomorrow at $(date --date="$parsed_date" +%H:%M)"
    else
        echo "tomorrow"
    fi
elif [ "$date_only" = "$yesterday" ]; then
    echo "yesterday"
elif [ "$diff" -gt 86400 ]; then
    # More than 1 day in future
    days=$((diff / 86400))
    echo "in ${days}d"
elif [ "$diff" -gt 0 ]; then
    # Less than 1 day in future
    hours=$((diff / 3600))
    minutes=$(((diff % 3600) / 60))
    echo "in ${hours}h${minutes}m"
else
    # Overdue (past dates)
    diff=$(( -diff ))  # convert to positive
    if [ "$diff" -gt 86400 ]; then
        days=$((diff / 86400))
        echo "${days}d ago"
    else
        hours=$((diff / 3600))
        minutes=$(((diff % 3600) / 60))
        echo "${hours}h${minutes}m ago"
    fi
fi
