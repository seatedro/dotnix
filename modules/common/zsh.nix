{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    enabled
    removeAttrs
    ;
in
{
  programs.zsh.enable = true;

  environment.shells = [ pkgs.zsh ];

  home-manager.sharedModules = [
    {
      programs.zsh = enabled {
        autocd = true;
        enableCompletion = true;

        autosuggestion = enabled { };
        syntaxHighlighting = enabled { };
        historySubstringSearch = enabled { };

        history = {
          size = 100000;
          save = 100000;
          ignoreAllDups = true;
          ignoreSpace = true;
          extended = true;
          share = true;
        };

        setOptions = [
          "GLOB_DOTS"
          "CORRECT"
          "COMPLETE_IN_WORD"
          "NO_BEEP"
          "INTERACTIVE_COMMENTS"
        ];

        sessionVariables = {
          PAGER = "less";
        };

        shellAliases = config.environment.shellAliases // {
          cdtmp = "cd $(mktemp -d)";
          kc = "kubectl";
          rebuild = "sudo nixos-rebuild switch --flake \"path:/nix-config#$(hostname)\"";
        };

        envExtra = ''
          export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"
          eval "$(direnv hook zsh)"
        '';

        initContent = ''
          # Completion styling
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
          zstyle ':completion:*' menu select
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' special-dirs true
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path ~/.zsh/cache
          zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
          zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
          zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
          zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
          zstyle ':completion:*' group-name '''
          zstyle ':completion:*' verbose yes
          zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
          zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

          # Integrations
          eval "$(zoxide init zsh)"
          eval "$(carapace _carapace)"

          # Edit command line in $EDITOR
          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey '^e' edit-command-line
          bindkey -s '^f' 'tmux-sessionizer\n'

          # Yazi directory wrapper
          function y() {
            local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
            yazi "$@" --cwd-file="$tmp"
            IFS= read -r -d ''' cwd < "$tmp"
            [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
            rm -f -- "$tmp"
          }

          # Git worktree helper
          gwt() {
            local search_dirs=("$HOME/exa" "$HOME/personal")

            local display_path=$(fd -H -u -t d '^\.git$' --max-depth 5 ''${search_dirs[@]} 2>/dev/null | \
              rg -v '/\.git/worktrees/' | \
              sed 's|/\.git/$||' | \
              sed "s|$HOME/||" | \
              fzf --prompt="Select git repo: " --height=40% --reverse)

            [[ -z "$display_path" ]] && return

            local git_root="$HOME/$display_path"
            local repo_name=$(basename "$git_root")

            echo -n "Branch name: "
            read branch_name
            [[ -z "$branch_name" ]] && return

            local kebab_branch=$(echo "$branch_name" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]')
            local worktree_dir="''${git_root}/../''${repo_name}-''${kebab_branch}"

            cd "$git_root"

            if git show-ref --verify --quiet refs/heads/$branch_name; then
              git worktree add "$worktree_dir" "$branch_name"
            else
              git worktree add -b "$branch_name" "$worktree_dir"
            fi

            cd "$worktree_dir"
          }

          _ao_resolve_sync_paths() {
            emulate -L zsh
            setopt pipe_fail no_unset

            local common_dir="$1"
            local line path
            local -a defaults paths
            typeset -A seen

            defaults=(
              "AGENTS.override.md"
              ".agents"
              "personal/ro/plans"
              "personal/ro/notes"
            )

            if [[ -n "''${AO_SYNC_PATHS:-}" ]]; then
              paths=("''${(@s:,:)AO_SYNC_PATHS}")
            else
              paths=("''${defaults[@]}")
            fi

            if [[ -f "$common_dir/local/ao-sync-paths" ]]; then
              while IFS= read -r line; do
                line="''${line%%#*}"
                line="''${line#"''${line%%[![:space:]]*}"}"
                line="''${line%"''${line##*[![:space:]]}"}"
                [[ -z "$line" ]] && continue
                paths+=("$line")
              done < "$common_dir/local/ao-sync-paths"
            fi

            reply=()
            for path in "''${paths[@]}"; do
              path="''${path%/}"
              [[ -z "$path" ]] && continue
              [[ -n "''${seen[$path]-}" ]] && continue
              seen[$path]=1
              reply+=("$path")
            done
          }

          _ao_append_excludes_for_repo() {
            emulate -L zsh
            setopt pipe_fail no_unset

            local wt="$1"
            shift
            local exclude pattern
            local -a patterns
            patterns=("$@")

            exclude="$(git -C "$wt" rev-parse --git-path info/exclude 2>/dev/null)" || return 0
            touch "$exclude"
            for pattern in "''${patterns[@]}"; do
              rg -q -x -F -- "$pattern" "$exclude" || printf "\n%s\n" "$pattern" >> "$exclude"
            done
          }

          # Merge-and-fanout sync for any git repo using worktrees.
          sync_agents_overrides() {
            emulate -L zsh
            setopt pipe_fail no_unset

            local repo_root common_dir template_root rel wt src prev path candidate dir_pattern
            local has_repo_root=0
            local copied_template=0
            local copied_worktrees=0
            local is_file=0
            local is_dir=0

            local -a worktrees
            local -a ordered_worktrees
            local -a merged_paths
            local -a sync_paths
            local -a exclude_patterns

            typeset -A merged_sources
            typeset -A conflict_paths
            typeset -A exclude_seen

            _ao_merge_file() {
              local in_rel="$1"
              local in_src="$2"
              local in_wt="$3"

              if [[ -n "''${merged_sources[$in_rel]-}" ]]; then
                prev="''${merged_sources[$in_rel]}"
                if ! cmp -s "$prev" "$in_src"; then
                  conflict_paths[$in_rel]=1
                  if [[ "$in_wt" == "$repo_root" ]]; then
                    merged_sources[$in_rel]="$in_src"
                  fi
                fi
              else
                merged_sources[$in_rel]="$in_src"
              fi
            }

            repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
              echo "error: run this inside a git worktree" >&2
              return 1
            }

            common_dir="$(git rev-parse --git-common-dir 2>/dev/null)" || {
              echo "error: failed to resolve git common dir" >&2
              return 1
            }

            _ao_resolve_sync_paths "$common_dir"
            sync_paths=("''${reply[@]}")
            if (( ''${#sync_paths[@]} == 0 )); then
              echo "error: no sync paths configured" >&2
              return 1
            fi

            template_root="$common_dir/local/agents-overrides"
            mkdir -p "$template_root"

            while IFS= read -r wt; do
              worktrees+=("''${wt#worktree }")
            done < <(git -C "$repo_root" worktree list --porcelain | rg '^worktree ')

            for wt in "''${worktrees[@]}"; do
              if [[ "$wt" == "$repo_root" ]]; then
                has_repo_root=1
                break
              fi
            done
            if (( has_repo_root == 0 )); then
              worktrees+=("$repo_root")
            fi

            ordered_worktrees=("$repo_root")
            for wt in "''${worktrees[@]}"; do
              [[ "$wt" == "$repo_root" ]] && continue
              ordered_worktrees+=("$wt")
            done

            for wt in "''${ordered_worktrees[@]}"; do
              [[ -d "$wt" ]] || continue
              for path in "''${sync_paths[@]}"; do
                candidate="$wt/$path"
                if [[ -f "$candidate" ]]; then
                  _ao_merge_file "$path" "$candidate" "$wt"
                  continue
                fi
                if [[ -d "$candidate" ]]; then
                  while IFS= read -r src; do
                    rel="''${src#$wt/}"
                    [[ -n "$rel" ]] || continue
                    [[ -f "$src" ]] || continue
                    _ao_merge_file "$rel" "$src" "$wt"
                  done < <(rg --files "$candidate" | rg -v '/\.git/')
                fi
              done
            done

            while IFS= read -r rel; do
              [[ -n "$rel" ]] && merged_paths+=("$rel")
            done < <(print -rl -- ''${(k)merged_sources} | sort)

            if (( ''${#merged_paths[@]} == 0 )); then
              echo "warning: no sync files found in configured paths" >&2
              return 1
            fi

            fd -H -u -t f . "$template_root" -x rm -f '{}' >/dev/null 2>&1 || true
            for rel in "''${merged_paths[@]}"; do
              src="''${merged_sources[$rel]}"
              [[ -n "$src" ]] || continue
              mkdir -p "$template_root/''${rel:h}"
              cp "$src" "$template_root/$rel"
              ((copied_template++))
            done

            for path in "''${sync_paths[@]}"; do
              is_file=0
              is_dir=0
              for rel in "''${merged_paths[@]}"; do
                [[ "$rel" == "$path" ]] && is_file=1
                [[ "$rel" == "$path/"* ]] && is_dir=1
              done
              if (( is_file == 1 )); then
                if [[ -z "''${exclude_seen[$path]-}" ]]; then
                  exclude_seen[$path]=1
                  exclude_patterns+=("$path")
                fi
              fi
              if (( is_dir == 1 || is_file == 0 )); then
                dir_pattern="$path/"
                if [[ -z "''${exclude_seen[$dir_pattern]-}" ]]; then
                  exclude_seen[$dir_pattern]=1
                  exclude_patterns+=("$dir_pattern")
                fi
              fi
            done

            for wt in "''${worktrees[@]}"; do
              [[ -d "$wt" ]] || continue
              _ao_append_excludes_for_repo "$wt" "''${exclude_patterns[@]}"
              for rel in "''${merged_paths[@]}"; do
                src="''${merged_sources[$rel]}"
                [[ -n "$src" ]] || continue
                if [[ "$src" == "$wt/$rel" ]]; then
                  continue
                fi
                if [[ -f "$wt/$rel" ]] && cmp -s "$src" "$wt/$rel"; then
                  continue
                fi
                mkdir -p "$wt/''${rel:h}"
                cp "$src" "$wt/$rel"
                ((copied_worktrees++))
              done
            done

            if (( ''${#conflict_paths[@]} > 0 )); then
              echo "note: resolved ''${#conflict_paths[@]} conflicting path(s); current worktree content was preferred"
            fi
            echo "synced ''${copied_template} template file(s) + ''${copied_worktrees} worktree copy operation(s)"
          }

          ao_install_post_checkout_hook() {
            emulate -L zsh
            setopt pipe_fail no_unset

            local common_dir hook_path
            common_dir="$(git rev-parse --git-common-dir 2>/dev/null)" || {
              echo "error: run this inside a git repository" >&2
              return 1
            }

            hook_path="$common_dir/hooks/post-checkout"
            mkdir -p "''${hook_path:h}"

            cat > "$hook_path" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

common_dir="$(git rev-parse --git-common-dir)"
repo_root="$(git rev-parse --show-toplevel)"
template_root="$common_dir/local/agents-overrides"
paths_file="$common_dir/local/ao-sync-paths"
legacy_root_file="$common_dir/local/AGENTS.override.md"

if [ ! -d "$template_root" ] && [ -s "$legacy_root_file" ]; then
  mkdir -p "$template_root"
  cp "$legacy_root_file" "$template_root/AGENTS.override.md"
fi

[ -d "$template_root" ] || exit 0

while IFS= read -r -d $'\0' src; do
  rel="''${src#"$template_root/"}"
  dst="$repo_root/$rel"
  if [ ! -f "$dst" ]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
  fi
done < <(fd -H -u -t f . "$template_root" -0)

sync_paths="''${AO_SYNC_PATHS:-AGENTS.override.md,.agents,personal/ro/plans,personal/ro/notes}"
IFS=',' read -r -a raw_paths <<< "$sync_paths"

if [ -f "$paths_file" ]; then
  while IFS= read -r line; do
    line="''${line%%#*}"
    line="''${line#"''${line%%[![:space:]]*}"}"
    line="''${line%"''${line##*[![:space:]]}"}"
    [ -z "$line" ] && continue
    raw_paths+=("$line")
  done < "$paths_file"
fi

exclude="$(git rev-parse --git-path info/exclude)"
touch "$exclude"

declare -A seen=()
for path in "''${raw_paths[@]}"; do
  path="''${path%/}"
  [ -z "$path" ] && continue
  if [ -n "''${seen[$path]:-}" ]; then
    continue
  fi
  seen[$path]=1

  if [ -f "$repo_root/$path" ] || [ -f "$template_root/$path" ]; then
    pattern="$path"
  else
    pattern="$path/"
  fi

  rg -q -x -F -- "$pattern" "$exclude" || printf "\n%s\n" "$pattern" >> "$exclude"
done
EOF

            chmod +x "$hook_path"
            echo "installed post-checkout hook: $hook_path"
          }

          alias ao='sync_agents_overrides'
          alias ao-sync='sync_agents_overrides'
          alias ao-install-hook='ao_install_post_checkout_hook'

        '';
      };
    }
  ];
}
