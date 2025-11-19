# Contributing to Omarchy ARM64 VM

Thank you for your interest in contributing! This project provides Omarchy Linux running on ARM64 for Apple Silicon Macs via UTM.

## How to Contribute

### Reporting Issues

When reporting issues, please include:
- Your Mac model (M1, M2, M3, etc.)
- UTM version
- macOS version
- Steps to reproduce the issue
- Screenshots if applicable

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/improvement`)
3. **Make your changes**
4. **Test thoroughly** - Verify the VM boots and works properly
5. **Commit with clear messages** (`git commit -m 'Add feature: description'`)
6. **Push to your fork** (`git push origin feature/improvement`)
7. **Open a Pull Request**

## Development Guidelines

### Scripts

- Use `#!/bin/bash` or `#!/usr/bin/env bash` for scripts
- Add comments explaining non-obvious sections
- Test scripts before committing
- Make scripts executable: `chmod +x script.sh`

### Documentation

- Keep documentation up-to-date with code changes
- Use clear, concise language
- Include examples where helpful
- Update relevant docs when changing functionality

### Configuration Files

- Preserve Omarchy's default configurations where possible
- Document any deviations from official Omarchy
- Explain ARM64-specific workarounds

## Areas for Contribution

### High Priority

- **Installer Scripts** - Automated VM creation/configuration
- **Package Updates** - Keep package lists current
- **Performance Improvements** - GPU acceleration, rendering optimizations
- **Bug Fixes** - Display issues, app compatibility

### Welcome Contributions

- **Documentation** - Setup guides, troubleshooting tips
- **App Compatibility** - Testing apps on ARM64
- **Configuration Tweaks** - Hyprland/Waybar improvements
- **Utility Scripts** - Helpful automation tools

## Testing

Before submitting, please test:

1. **Clean VM Build** - Does it work from scratch?
2. **Display Output** - Does Hyprland render properly?
3. **Key Applications** - Do core apps (terminal, browser, etc.) work?
4. **Scripts** - Do automation scripts execute without errors?

## Code Style

- **Shell Scripts**: Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- **Markdown**: Use consistent formatting, proper headers
- **Comments**: Explain "why" not just "what"

## Architecture Constraints

This project works within specific limitations:

- **ARM64 only** - No x86_64 support
- **UTM/QEMU** - virtio-gpu with OpenGL 2.1 limitation
- **No official Omarchy installer** - Manual configuration required
- **Package availability** - Some x86_64-only apps unavailable

## Questions?

- Open a GitHub issue for discussion
- Check existing issues for similar questions
- Review documentation in `docs/`

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for helping improve Omarchy ARM64 VM!**
