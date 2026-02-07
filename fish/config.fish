if status is-interactive
set -gx STARSHIP_CONFIG ~/.config/starship.toml

starship init fish | source
end

alias lvim="env NVIM_APPNAME=lvim ~/.local/bin/lvim"
fish_add_path ~/.local/bin

#function fastfetch
    # Abre um novo terminal kitty com a classe que dispara a regra e roda o fastfetch
#    kitty --class fastfetch_term -e sh -c "fastfetch; read"
#end
