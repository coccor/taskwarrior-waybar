# Contributing to Taskwarrior Waybar Integration

Thank you for considering contributing to this project! Here are some guidelines to help you get started.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear description of the problem
- Steps to reproduce the issue
- Your environment (OS, shell, Taskwarrior version, etc.)
- Any relevant error messages or logs

### Suggesting Features

Feature requests are welcome! Please open an issue describing:
- What you'd like to see added
- Why it would be useful
- Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear, descriptive messages
6. Push to your branch
7. Open a Pull Request

### Code Style

- Use bash best practices
- Include comments for complex logic
- Follow existing code formatting
- Use meaningful variable names
- Add error handling where appropriate

### Testing

Before submitting a PR, please test:
- All scripts run without errors
- The installer works on a fresh system
- No breaking changes to existing functionality
- Waybar updates correctly

### Documentation

Update the README.md if you:
- Add new features
- Change existing functionality
- Add new configuration options
- Fix important bugs

## Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/taskwarrior-waybar.git
cd taskwarrior-waybar

# Make changes to scripts in the scripts/ directory

# Test manually
./scripts/taskwarrior-status.sh
./scripts/taskwarrior-add.sh

# Test installer
./install.sh
```

## Questions?

Feel free to open an issue for any questions or discussions.

Thank you for contributing!
