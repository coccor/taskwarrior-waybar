#!/bin/bash
# Taskwarrior Waybar Integration - Installation Script
#
# This script installs all necessary components for taskwarrior-waybar integration

set -eEo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAYBAR_SCRIPTS_DIR="${HOME}/.config/waybar/scripts"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
WAYBAR_CONFIG="${HOME}/.config/waybar/config.jsonc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check dependencies
check_dependencies() {
    print_step "Checking dependencies..."

    local missing_deps=()

    command -v task >/dev/null 2>&1 || missing_deps+=("task (taskwarrior)")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v notify-send >/dev/null 2>&1 || missing_deps+=("libnotify/notify-send")

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install them with:"
        echo "  sudo pacman -S task jq libnotify"
        echo ""
        exit 1
    fi

    print_success "All dependencies installed"
}

# Install scripts
install_scripts() {
    print_step "Installing scripts to ${WAYBAR_SCRIPTS_DIR}..."

    mkdir -p "${WAYBAR_SCRIPTS_DIR}"

    for script in "${REPO_DIR}/scripts"/*.sh; do
        script_name=$(basename "$script")
        cp "$script" "${WAYBAR_SCRIPTS_DIR}/${script_name}"
        chmod +x "${WAYBAR_SCRIPTS_DIR}/${script_name}"
        print_success "Installed ${script_name}"
    done
}

# Install systemd units
install_systemd() {
    print_step "Installing systemd user units..."

    mkdir -p "${SYSTEMD_USER_DIR}"

    for unit in "${REPO_DIR}/systemd"/*; do
        unit_name=$(basename "$unit")
        cp "$unit" "${SYSTEMD_USER_DIR}/${unit_name}"
        print_success "Installed ${unit_name}"
    done

    print_step "Enabling and starting systemd timer..."
    systemctl --user daemon-reload
    systemctl --user enable taskwarrior-notify.timer
    systemctl --user start taskwarrior-notify.timer

    print_success "Systemd timer enabled and started"
}

# Configure waybar
configure_waybar() {
    print_step "Configuring waybar module..."

    if [ ! -f "${WAYBAR_CONFIG}" ]; then
        print_warning "Waybar config not found at ${WAYBAR_CONFIG}"
        print_warning "Please manually add the taskwarrior module to your waybar config"
        echo ""
        echo "Add to modules-center or modules-left/right:"
        echo '  "custom/taskwarrior-status"'
        echo ""
        echo "Add this configuration:"
        cat <<'EOF'
  "custom/taskwarrior-status": {
    "format": "{icon}",
    "format-icons": {
      "default": "  ",
      "due": "  !"
    },
    "return-type": "json",
    "exec": "$HOME/.config/waybar/scripts/taskwarrior-status.sh",
    "interval": 60,
    "tooltip": true,
    "on-click": "alacritty -e bash -c '$HOME/.config/waybar/scripts/taskwarrior-add.sh'",
    "on-click-right": "alacritty -e bash -c '$HOME/.config/waybar/scripts/taskwarrior-done.sh'"
  }
EOF
        echo ""
        return
    fi

    # Check if module already exists
    if grep -q "custom/taskwarrior-status" "${WAYBAR_CONFIG}"; then
        print_success "Taskwarrior module already configured in waybar"
    else
        print_warning "Taskwarrior module not found in waybar config"
        print_warning "Please manually add it (see README.md for configuration)"
    fi
}

# Main installation
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   Taskwarrior Waybar Integration - Installer           ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""

    check_dependencies
    install_scripts
    install_systemd
    configure_waybar

    echo ""
    print_success "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart waybar: pkill waybar && waybar &"
    echo "  2. Add tasks: Left-click on the taskwarrior icon"
    echo "  3. Complete tasks: Right-click on the taskwarrior icon"
    echo "  4. View notifications: Enabled automatically every 5 minutes"
    echo ""
    echo "For more information, see README.md"
    echo ""
}

# Run installation
main
