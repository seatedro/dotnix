$env.config = {
  bracketed_paste:                  true
  buffer_editor:                    ""
  datetime_format:                  {}
  edit_mode:                        vi
  error_style:                      fancy
  float_precision:                  2
  footer_mode:                      25
  render_right_prompt_on_last_line: false
  show_banner:                      false
  use_ansi_coloring:                true
  use_kitty_protocol:               true

  shell_integration: {
    osc2:                   false
    osc7:                   true
    osc8:                   true
    osc9_9:                 false
    osc133:                 true
    osc633:                 true
    reset_application_mode: true
  }
}

$env.config.ls = {
  clickable_links: true
  use_ls_colors: true
}

$env.config.rm.always_trash = false

$env.config.history = {
  file_format:   sqlite
  isolation:     false
  max_size:      100_000
  sync_on_enter: true
}

$env.config.cursor_shape = {
  vi_insert: block
  vi_normal: block
}

$env.config.hooks = {
  command_not_found: {||}

  display_output: {
    tee { table --expand | print }
    | $env.last = $in
  }

  env_change: {
    PWD: ($env.config.hooks.env_change.PWD? | default [])
  }

  pre_execution: [
    {
      let prompt = commandline | str trim

      if ($prompt | is-empty) {
        return
      }

      print $"(ansi title)($prompt) — nu(char bel)"
    }
  ]

  pre_prompt: []
}

alias gg = nvim -c 'Neogit'
def rebuild [] { sudo nixos-rebuild switch --flake $"path:/nix-config#(hostname)" }
def gc [repo: any]: any -> any { git clone $"git@github.com:(($repo) | into string)" }


if $nu.is-interactive and ($env.YAZI_ID? | default "" | is-empty) {
  yazi
}

source ~/.cache/carapace/init.nu
