{ ... }:

{
  home-manager.sharedModules = [
    {
      xdg.configFile."tmux/tmux.conf".text = ''
        set -g default-terminal "tmux-256color"
        set -g terminal-features "xterm*:clipboard:ccolour:cstyle:focus:title,screen*:title,*:extkeys,xterm-256color:RGB,xterm-ghostty:RGB"
        set -g terminal-overrides "xterm-256color:Tc,xterm-ghostty:Tc"

        set -g mouse on
        set -g extended-keys always
        set -gq extended-keys-format csi-u
        set -g detach-on-destroy off
        set -g history-limit 10000
        set -g set-clipboard on
        setw -g mode-keys vi

        set -g prefix C-b
        unbind C-b
        bind C-b send-prefix

        bind '"' split-window -v
        bind % split-window -h
        bind z resize-pane -Z
        bind c new-window
        bind , command-prompt -I '#W' 'rename-window %%'
        bind p previous-window
        bind n next-window
        bind Left  select-pane -L
        bind Right select-pane -R
        bind Down  select-pane -D
        bind Up    select-pane -U
        bind h select-pane -L
        bind l select-pane -R
        bind j select-pane -D
        bind k select-pane -U
        bind o select-pane -t :.+
        bind d detach-client
        bind [ copy-mode

        bind C-p switch-client -T zellij-pane
        bind -T zellij-pane C-p switch-client -T root
        bind -T zellij-pane h select-pane -L
        bind -T zellij-pane l select-pane -R
        bind -T zellij-pane j select-pane -D
        bind -T zellij-pane k select-pane -U
        bind -T zellij-pane Left  split-window -h -b
        bind -T zellij-pane Right split-window -h
        bind -T zellij-pane Up    split-window -v -b
        bind -T zellij-pane Down  split-window -v
        bind -T zellij-pane x kill-pane
        bind -T zellij-pane f resize-pane -Z

        set -g status on
        set -g status-position bottom
        set -g status-interval 2
        set -g status-left-length 80
        set -g status-right-length 80
        set -g status-style 'fg=default,bg=default'
        set -g status-left '#{?client_prefix,#[bg=#ffc387] ,#[bg=#89B4FA] }#[default]#[bold] #S '
        set -g status-right '#($HOME/.local/bin/tmux-latency)#(TZ=America/Los_Angeles date "+%A, %d %b %Y %H:%M") '

        setw -g automatic-rename on
        setw -g window-status-separator ""
        setw -g window-status-format '#[default]#I #W #{?window_zoomed_flag,□ ,}#{?pane_synchronized,  ,}'
        setw -g window-status-current-format '#[default,bold,italics]#I #W #{?window_zoomed_flag,□ ,}#{?pane_synchronized,  ,}'

        set -g pane-border-style 'fg=#3c3836'
        set -g pane-active-border-style 'fg=#89B4FA'
        set -g message-style 'fg=#ebdbb2,bg=#3c3836'
        set -g mode-style 'fg=#282828,bg=#89B4FA'

        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi y send -X copy-selection-and-cancel
        bind -T copy-mode-vi C-j send -X halfpage-down
        bind -T copy-mode-vi C-k send -X halfpage-up
        bind -T copy-mode-vi n send -X search-again
        bind -T copy-mode-vi N send -X search-reverse
      '';

      home.file.".local/bin/tmux-latency" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          host="''${TMUX_LATENCY_HOST:-100.86.31.50}"
          ms=$(ping -c 1 -W 1 "$host" 2>/dev/null | sed -n 's/.*time=\([0-9.]*\).*/\1/p' | head -1 || true)
          if [ -n "$ms" ]; then
            printf '󰖩 %.0fms | ' "$ms"
          else
            printf '󰖩 -- | '
          fi
        '';
      };
    }
  ];
}
