{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  config = mkIf config.pywal.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "wal-set" ''
        #!/usr/bin/env bash

        # Set wallpaper and generate colors
        if [ $# -eq 0 ]; then
          echo "Usage: wal-set <image-path> [light|dark]"
          echo "       wal-set --theme <theme-name>"
          echo ""
          echo "Available preset themes:"
          wal --theme | grep " - " | sed 's/ - /: /'
          exit 1
        fi

        if [ "$1" = "--theme" ]; then
          # Use preset theme
          if [ "$3" = "light" ] || [[ "$2" == *"dawn"* ]] || [[ "$2" == *"light"* ]]; then
            wal -l -q --theme "$2"
          else
            wal -q --theme "$2"
          fi
        elif [ -f "$1" ]; then
          # Generate from image
          MODE=""
          if [ "$2" = "light" ]; then
            MODE="-l"
          fi
          wal -q -i "$1" $MODE
          
          # Set wallpaper with swww
          swww img "$1" --transition-type center --transition-step 10 --transition-fps 30
        else
          echo "Error: File not found: $1"
          exit 1
        fi

        # Copy generated configs to appropriate locations
        cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css 2>/dev/null || true
        cp ~/.cache/wal/colors-mako ~/.config/mako/colors 2>/dev/null || true
        cp ~/.cache/wal/colors-ghostty ~/.config/ghostty/colors 2>/dev/null || true
        cp ~/.cache/wal/colors-vicinae.toml ~/.config/vicinae/colors.toml 2>/dev/null || true

        # Enable colors source in hyprland.conf if not already done
        if ! grep -q "^source = ~/.cache/wal/colors-hypr" ~/.config/hypr/hyprland.conf; then
          sed -i 's|# source = ~/.cache/wal/colors-hypr|source = ~/.cache/wal/colors-hypr|' ~/.config/hypr/hyprland.conf
        fi

        # Reload applications
        pkill waybar 2>/dev/null || true
        sleep 0.5
        waybar & disown
        makoctl reload 2>/dev/null || true

        echo "Theme applied successfully!"
        echo "Colors saved to ~/.cache/wal/"
      '')

      (pkgs.writeShellScriptBin "wal-select" ''
        #!/usr/bin/env bash

        # Interactive wallpaper selector
        WALLPAPER_DIR="''${1:-$HOME/Documents/Wallpapers}"

        if [ ! -d "$WALLPAPER_DIR" ]; then
          WALLPAPER_DIR="$HOME/Pictures"
        fi

        if [ ! -d "$WALLPAPER_DIR" ]; then
          echo "No Pictures directory found. Please specify a directory:"
          echo "  wal-select /path/to/wallpapers"
          exit 1
        fi

        # Check for selector tool
        if command -v fzf >/dev/null 2>&1; then
          IMAGE=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) 2>/dev/null | fzf --preview 'file {}')
        elif command -v wofi >/dev/null 2>&1; then
          IMAGE=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) 2>/dev/null | wofi --dmenu --prompt "Select wallpaper")
        else
          echo "Neither fzf nor wofi found. Please install one:"
          echo "  nix-shell -p fzf"
          exit 1
        fi

        if [ -n "$IMAGE" ]; then
          wal-set "$IMAGE"
        fi
      '')

      (pkgs.writeShellScriptBin "wal-random" ''
        #!/usr/bin/env bash

        # Set random wallpaper from directory
        WALLPAPER_DIR="''${1:-$HOME/Pictures/Wallpapers}"

        if [ ! -d "$WALLPAPER_DIR" ]; then
          WALLPAPER_DIR="$HOME/Pictures"
        fi

        if [ ! -d "$WALLPAPER_DIR" ]; then
          echo "No Pictures directory found. Please specify a directory:"
          echo "  wal-random /path/to/wallpapers"
          exit 1
        fi

        # Find random image
        IMAGE=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) 2>/dev/null | shuf -n 1)

        if [ -n "$IMAGE" ]; then
          echo "Setting wallpaper: $IMAGE"
          wal-set "$IMAGE"
        else
          echo "No images found in $WALLPAPER_DIR"
          exit 1
        fi
      '')
    ];
  };
}
