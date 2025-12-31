# AGENTS.md

This file provides guidance to any Agent when working with code in this repository.

Never add comments when making code changes

## Repository Overview

This is seatedro's personal NixOS configuration repository - a modular, flake-based configuration supporting both NixOS (Linux) and nix-darwin (macOS) systems. The configuration uses modern Nix practices with a clean modular architecture.

## Host Configurations

- **thanatos** - Primary desktop (x86_64-linux, Wayland/Hyprland, AMD CPU + Nvidia GPU)
- **volt** - VM environment (aarch64-linux, X11/bspwm, VMware guest)  
- **nori** - macOS system (aarch64-darwin)

## Common Commands

### System Management

```bash
# Build and apply configuration
sudo nixos-rebuild switch --flake path:/nix-config#thanatos
# the path: is necessary because there are font files that must not be included in git.

# Format Nix code
nixfmt

# Update flake inputs
nix flake update

# Check flake validity
nix flake check
```

### Direct Nix Commands

```bash
# NixOS systems
sudo nixos-rebuild switch --flake ".#thanatos"

# Darwin systems  
darwin-rebuild switch --flake ".#nori"

# Build specific configurations
nix build ".#nixosConfigurations.thanatos.config.system.build.toplevel"
```

### VM Deployment

```bash
# Copy configuration to VM (requires NIXADDR, NIXPORT, NIXUSER env vars)
make vm/copy

# Apply configuration on remote VM
make vm/switch

# Full VM bootstrap from scratch
make vm/bootstrap
```

## Architecture

### Directory Structure

- `flake.nix` - Main flake with inputs/outputs and host definitions
- `hosts/` - Host-specific configurations and imports
- `modules/common/` - Shared modules (packages, nushell, direnv, etc.)
- `modules/nixos/` - NixOS-specific modules (desktop environments, system config)
- `modules/darwin/` - macOS-specific modules (dock, input, system preferences)
- `lib/` - Custom library functions extending nixpkgs.lib
- `.config/` - Application-specific configuration files

### Module System

Modules use `mkEnableOption` pattern for conditional enabling. Host configurations import relevant modules via the custom `collectNix` function. Each module should be self-contained and toggleable.

### Desktop Environments

- **Wayland Stack**: Hyprland + Waybar + Mako + Wofi (thanatos)
- **X11 Stack**: bspwm + Polybar + Rofi + dunst (volt)

### Key Technologies

- **Shell**: Nushell (primary), with Fish/Zsh alternatives
- **Editors**: Neovim, Helix, Vim  
- **Terminal**: Alacritty, Ghostty
- **Languages**: Go, Rust, Zig, Node.js, Bun
- **Custom packages**: glimpse, vicinae, zjstatus

### User Configuration

- **User**: `ro` (UID 1000 on Linux, 501 on macOS)
- **Home**: `/home/ro` (Linux), `/Users/ro` (macOS)
- **Shell**: Nushell as default
- **SSH**: Ed25519 key authentication

## Development Workflow

1. Make changes to modules or host configurations
2. Test changes with `make test` 
3. Apply with `make switch`
4. Format code with `nix fmt` before committing
5. Use `nix flake update` to update inputs when needed

## Cache Configuration

The configuration uses multiple binary caches for faster builds:
- cache.garnix.io
- nix-community.cachix.org  
- hyprland.cachix.org
- vicinae.cachix.org

## Environment Variables

For VM operations, set:
- `NIXADDR` - VM IP address
- `NIXPORT` - SSH port (default: 22)
- `NIXUSER` - SSH user (default: ro)
- `NIXNAME` - Host configuration name (default: volt)
