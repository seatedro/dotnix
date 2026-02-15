{ config, pkgs, lib, ... }:

let
  # gruvbox dark hard colors
  colors = {
    bg0_hard = "#1d2021";
    bg0 = "#282828";
    bg1 = "#3c3836";
    bg2 = "#504945";
    bg3 = "#665c54";
    bg4 = "#7c6f64";
    fg0 = "#fdf4c1";
    fg1 = "#ebdbb2";
    fg2 = "#d5c4a1";
    fg3 = "#bdae93";
    fg4 = "#a89984";
    red = "#cc241d";
    green = "#98971a";
    yellow = "#d79921";
    purple = "#b16286";
    aqua = "#689d6a";
    orange = "#d65d0e";
    bright_red = "#fb4934";
    bright_green = "#b8bb26";
    bright_yellow = "#fabd2f";
    bright_purple = "#d3869b";
    bright_aqua = "#8ec07c";
    bright_orange = "#fe8019";
  };
in
{
  home-manager.sharedModules = [
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "tmux-256color";
        prefix = "C-b";
        baseIndex = 0;
        escapeTime = 0;
        mouse = true;
        keyMode = "vi";
        historyLimit = 50000;

        plugins = with pkgs.tmuxPlugins; [
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-capture-pane-contents 'on'
              set -g @resurrect-strategy-nvim 'session'
            '';
          }
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '15'
            '';
          }
        ];

        extraConfig = ''
          # true color
          set -ag terminal-overrides ",*:RGB"
          set -g allow-passthrough on

          # renumber windows
          set -g renumber-windows on

          # splits in cwd
          bind \\ split-window -h -c "#{pane_current_path}"
          bind Enter split-window -v -c "#{pane_current_path}"

          # new window in cwd
          bind c new-window -c "#{pane_current_path}"

          # pane nav without prefix (alt+hjkl)
          bind -n M-h select-pane -L
          bind -n M-j select-pane -D
          bind -n M-k select-pane -U
          bind -n M-l select-pane -R

          # pane nav with prefix (fallback)
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R

          # resize without prefix (alt+shift+hjkl)
          bind -n M-H resize-pane -L 5
          bind -n M-J resize-pane -D 5
          bind -n M-K resize-pane -U 5
          bind -n M-L resize-pane -R 5

          # window nav without prefix
          bind -n M-0 select-window -t 0
          bind -n M-1 select-window -t 1
          bind -n M-2 select-window -t 2
          bind -n M-3 select-window -t 3
          bind -n M-4 select-window -t 4
          bind -n M-5 select-window -t 5
          bind -n M-6 select-window -t 6
          bind -n M-7 select-window -t 7
          bind -n M-8 select-window -t 8
          bind -n M-9 select-window -t 9
          bind -n M-n next-window
          bind -n M-p previous-window

          # quick actions
          bind x kill-pane
          bind X kill-window
          bind z resize-pane -Z

          # session switcher (fuzzy)
          bind s display-popup -E -w 40% -h 40% -S "fg=${colors.bg2}" -b rounded \
              "tmux list-sessions -F '#S' | fzf --reverse --border=none --margin=1 --padding=1 \
              --prompt='  ' --pointer='▌' --no-scrollbar \
              --color=bg:${colors.bg0_hard},bg+:${colors.bg2},fg:${colors.fg4},fg+:${colors.fg1},hl:${colors.bright_orange},hl+:${colors.bright_orange},pointer:${colors.bright_orange},prompt:${colors.bright_orange},info:${colors.bg4} \
              | xargs -I{} tmux switch-client -t {}"

          # last session
          bind L switch-client -l

          # reload
          bind r source-file ~/.config/tmux/tmux.conf \; display "reloaded"

          # copy mode
          bind -T copy-mode-vi v send -X begin-selection
          bind -T copy-mode-vi y send -X copy-selection-and-cancel

          # reduce scroll speed (default is 5 lines per tick)
          bind -T copy-mode-vi WheelUpPane send-keys -X -N 2 scroll-up
          bind -T copy-mode-vi WheelDownPane send-keys -X -N 2 scroll-down

          # no bells
          set -g visual-activity off
          set -g visual-bell off
          set -g visual-silence off
          setw -g monitor-activity off
          set -g bell-action none

          # status bar
          set -g status-position top
          set -g status-justify left
          set -g status-style "bg=${colors.bg1} fg=${colors.fg1}"
          set -g status-interval 1

          # left: session
          set -g status-left "#[bg=${colors.bright_orange},fg=${colors.bg0_hard},bold] #S #[bg=${colors.bg1},fg=${colors.bright_orange}] "
          set -g status-left-length 20

          # right: time only
          set -g status-right "#[fg=${colors.fg4}]%-I:%M %p "
          set -g status-right-length 50

          # window format
          setw -g window-status-format "#[fg=${colors.fg4}] #I #W "
          setw -g window-status-current-format "#[fg=${colors.bright_yellow},bold] #I #W "
          setw -g window-status-separator ""

          # pane borders
          set -g pane-border-lines simple
          set -g pane-border-style "fg=${colors.bg2}"
          set -g pane-active-border-style "fg=${colors.bright_orange}"

          # message style
          set -g message-style "bg=${colors.bright_yellow} fg=${colors.bg0_hard}"
          set -g message-command-style "bg=${colors.bright_yellow} fg=${colors.bg0_hard}"

          # mode style (copy mode)
          setw -g mode-style "bg=${colors.bright_orange} fg=${colors.bg0_hard}"

          # clock
          setw -g clock-mode-colour "${colors.bright_yellow}"
        '';
      };
    }
  ];
}
