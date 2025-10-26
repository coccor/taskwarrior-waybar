# Taskwarrior Waybar Integration

A beautiful, modern integration between [Taskwarrior](https://taskwarrior.org/) and [Waybar](https://github.com/Alexays/Waybar) for managing tasks directly from your status bar.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)

## Features

- 📋 **Status Display** - View up to 10 upcoming tasks sorted by due date
- 🎨 **Modern Styling** - Color-coded by urgency with priority indicators
- ➕ **Quick Add** - Add tasks with natural language due dates (5min, 1h, tomorrow)
- ✅ **Easy Completion** - Mark tasks as done with a simple interface
- 🔔 **Smart Notifications** - Get alerted 5 minutes before tasks are due
- 🕐 **Human-Friendly Times** - "today in 2h", "tomorrow at 14:30", "3d ago"
- 🌍 **Timezone Aware** - Correctly handles UTC timestamps from Taskwarrior

## Screenshots
![screenshot1](/assets/image.png)

### Tooltip Display
```
📋 Tasks (4 pending, 1 overdue)

● Project review     ⏰ today 30m ago     [overdue, high priority]
● Team meeting       📅 today in 2h15m    [due today]
  Code deployment    📅 tomorrow at 09:00
  Write documentation  in 3d
```

### Notifications
- Proactive alerts 5 minutes before tasks are due
- Shows overdue count and upcoming tasks
- Formatted list with humanized times

## Installation

### Prerequisites

- [Taskwarrior](https://taskwarrior.org/) - Task management tool
- [Waybar](https://github.com/Alexays/Waybar) - Status bar for Wayland
- `jq` - JSON processor
- `libnotify` - Desktop notifications
- A terminal emulator (default: `alacritty`)

On Arch Linux:
```bash
sudo pacman -S task waybar jq libnotify alacritty
```

### Quick Install

```bash
git clone https://github.com/coccor/taskwarrior-waybar.git ~/Work/taskwarrior-waybar
cd ~/Work/taskwarrior-waybar
./install.sh
```

The installer will:
1. Check for required dependencies
2. Install scripts to `~/.config/waybar/scripts/`
3. Install systemd units for notifications
4. Enable and start the notification timer

### Manual Installation

1. **Copy scripts:**
   ```bash
   cp scripts/* ~/.config/waybar/scripts/
   chmod +x ~/.config/waybar/scripts/taskwarrior-*.sh
   chmod +x ~/.config/waybar/scripts/humanize-date.sh
   ```

2. **Install systemd units:**
   ```bash
   cp systemd/* ~/.config/systemd/user/
   systemctl --user daemon-reload
   systemctl --user enable --now taskwarrior-notify.timer
   ```

3. **Configure Waybar** - Add to your `~/.config/waybar/config.jsonc`:

   Add to `modules-center`, `modules-left`, or `modules-right`:
   ```json
   "custom/taskwarrior-status"
   ```

   Add the module configuration:
   ```json
   "custom/taskwarrior-status": {
     "format": "{icon}",
     "format-icons": {
        "default": "  ",
        "due": "  !"
     },
     "return-type": "json",
     "exec": "$HOME/.config/waybar/scripts/taskwarrior-status.sh",
     "interval": 60,
     "tooltip": true,
     "on-click": "alacritty -e bash -c '$HOME/.config/waybar/scripts/taskwarrior-add.sh'",
     "on-click-right": "alacritty -e bash -c '$HOME/.config/waybar/scripts/taskwarrior-done.sh'"
   }
   ```

4. **Restart Waybar:**
   ```bash
   pkill waybar && waybar &
   ```

## Usage

### Status Display

Hover over the taskwarrior icon in waybar to see:
- Number of pending and overdue tasks
- Up to 10 tasks sorted by due date
- Color-coded urgency:
  - 🔴 **Red** - Overdue tasks
  - 🟡 **Yellow** - Due today
  - 🔵 **Blue** - Due tomorrow
  - ⚪ **Gray** - Future tasks
- Priority indicators:
  - 🔴 **●** High priority
  - 🟡 **●** Medium priority
  - 🔵 **●** Low priority

### Adding Tasks

**Left-click** the taskwarrior icon to open the add dialog.

Enter task description and optional due date:
- `5min` - Due in 5 minutes
- `1h` - Due in 1 hour
- `2d` - Due in 2 days
- `tomorrow` - Due tomorrow
- `2025-12-25` - Specific date
- Leave blank for no due date

The script automatically converts relative times (like `5min`) to `now+5min` for Taskwarrior.

### Completing Tasks

**Right-click** the taskwarrior icon to open the completion dialog.

- View all pending tasks
- Enter task ID to mark as done
- Press Enter (empty input) to complete the most urgent task

### Notifications

Notifications are triggered automatically every 5 minutes for:
- Overdue tasks
- Tasks due within the next 5 minutes

**Manage the notification service:**
```bash
# Check status
systemctl --user status taskwarrior-notify.timer

# Stop notifications
systemctl --user stop taskwarrior-notify.timer

# Start notifications
systemctl --user start taskwarrior-notify.timer

# Change frequency (edit timer file)
systemctl --user edit taskwarrior-notify.timer
```

## Scripts

### `taskwarrior-status.sh`
Generates JSON output for waybar tooltip display.
- Queries pending tasks from Taskwarrior
- Sorts by due date
- Formats with modern styling

### `taskwarrior-add.sh`
Interactive script for adding tasks.
- Prompts for description and due date
- Auto-converts relative times
- Validates input

### `taskwarrior-done.sh`
Interactive script for completing tasks.
- Displays all pending tasks
- Allows selection by ID
- Default to most urgent task

### `taskwarrior-notify.sh`
Notification daemon for due tasks.
- Checks for overdue tasks
- Checks for tasks due in next 5 minutes
- Sends desktop notifications with humanized times

### `humanize-date.sh`
Utility for converting dates to human-readable format.
- Handles Taskwarrior ISO format (UTC)
- Timezone-aware conversion
- Natural language output

**Usage:**
```bash
# Taskwarrior format
humanize-date.sh "20251026T210000Z"
# Output: today in 10h22m

# Standard format
humanize-date.sh "2025-10-27 14:30:00"
# Output: tomorrow at 14:30
```

## Customization

### Change Terminal Emulator

Edit `~/.config/waybar/config.jsonc`:
```json
"on-click": "kitty -e bash -c '$HOME/.config/waybar/scripts/taskwarrior-add.sh'",
"on-click-right": "kitty -e bash -c '$HOME/.config/waybar/scripts/taskwarrior-done.sh'"
```

Replace `alacritty` with your preferred terminal (`kitty`, `foot`, `gnome-terminal`, etc.).

### Change Colors

Edit `taskwarrior-status.sh` and modify the color codes:
```bash
# Overdue
foreground='#ff6b6b'

# Due today
foreground='#feca57'

# Due tomorrow
foreground='#48dbfb'
```

### Change Update Interval

Edit `~/.config/waybar/config.jsonc`:
```json
"interval": 30,  // Update every 30 seconds
```

### Change Notification Frequency

Edit `~/.config/systemd/user/taskwarrior-notify.timer`:
```ini
OnUnitActiveSec=2min  # Check every 2 minutes instead of 5
```

Then reload:
```bash
systemctl --user daemon-reload
systemctl --user restart taskwarrior-notify.timer
```

### Add Middle-Click Action

Edit `~/.config/waybar/config.jsonc`:
```json
"on-click-middle": "alacritty -e task"
```

## Troubleshooting

### Notifications not working

Check the systemd service:
```bash
systemctl --user status taskwarrior-notify.timer
systemctl --user status taskwarrior-notify.service
```

Check logs:
```bash
journalctl --user -u taskwarrior-notify.service -f
```

Test manually:
```bash
~/.config/waybar/scripts/taskwarrior-notify.sh
```

### Waybar not updating

- Check if the script runs manually:
  ```bash
  ~/.config/waybar/scripts/taskwarrior-status.sh
  ```
- Restart waybar:
  ```bash
  pkill waybar && waybar &
  ```
- Check waybar logs for errors

### Times showing incorrectly

Make sure your system timezone is set correctly:
```bash
timedatectl status
```

The scripts handle UTC timestamps from Taskwarrior automatically.

### Tasks not appearing

Check if you have pending tasks:
```bash
task +PENDING
```

Check the JSON export:
```bash
task +PENDING export | jq
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Credits

Created to enhance productivity with Taskwarrior and Waybar.

Special thanks to:
- [Taskwarrior](https://taskwarrior.org/) team
- [Waybar](https://github.com/Alexays/Waybar) developers

## Related Projects

- [taskwarrior-tui](https://github.com/kdheepak/taskwarrior-tui) - Terminal UI for Taskwarrior
- [vit](https://github.com/vit-project/vit) - Visual Interactive Taskwarrior
- [Timewarrior](https://timewarrior.net/) - Time tracking companion to Taskwarrior

## Changelog

### v1.0.0 (2025-10-26)
- Initial release
- Status display with modern styling
- Quick add and completion scripts
- Smart notifications
- Humanized date/time display
- Timezone-aware timestamp handling
- Up to 10 tasks sorted by due date
- Priority indicators
- Color-coded urgency levels
