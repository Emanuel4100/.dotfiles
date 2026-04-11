if status is-interactive
    # Commands to run in interactive sessions can go here
    fastfetch
end

# opencode
if test -d "$HOME/.opencode/bin"
    fish_add_path "$HOME/.opencode/bin"
end
alias files='nautilus .'
