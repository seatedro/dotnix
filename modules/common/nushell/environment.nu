$env.ENV_CONVERSIONS.PATH = {
  from_string: {|string|
    $string | split row (char esep) | path expand --no-symlink
  }
  to_string: {|value|
    $value | path expand --no-symlink | str join (char esep)
  }
}

$env.LS_COLORS = (if ("~/.config/nushell/ls_colors.txt" | path exists) { 
  open ~/.config/nushell/ls_colors.txt 
} else {
  vivid generate snazzy 
})

source ~/.config/nushell/zoxide.nu
source ~/.config/nushell/starship.nu

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

# Path additions
use std/util "path add"
path add ~/.bun/bin
path add ~/.cargo/bin

def copy []: string -> nothing {
	print --no-newline $"(ansi osc)52;c;($in | encode base64)(ansi st)"
}

def today []: nothing -> string {
  date now | format date "%Y-%m-%d"
}

def --env mc [path: path]: nothing -> nothing {
  mkdir $path
  cd $path
}

def --env mcg [path: path]: nothing -> nothing {
  mkdir $path
  cd $path
  jj git init --colocate
}
