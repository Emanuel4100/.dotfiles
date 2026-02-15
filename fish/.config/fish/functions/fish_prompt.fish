function fish_prompt
    # NvChad-inspired Palette
    set -l blue 61afef
    set -l green 98c379
    set -l purple c678dd
    set -l red e06c75
    set -l black 1e222a
    set -l grey 3b4048
    set -l white abb2bf

    # Icons
    set -l icon_os " " # Change based on your OS
    set -l icon_dir " "
    set -l icon_git " "
    set -l separator ""

    set -l last_status $status

    # Helper function to draw segments
    function _draw_segment -a bg fg content
        set_color -b $bg
        set_color $fg
        echo -n " $content "
        set_color -b normal
        set_color $bg
    end

    # 1. OS / Host Segment (Blue)
    _draw_segment $blue $black "$icon_os$USER"
    set_color $blue
    set_color -b $grey
    echo -n "$separator"

    # 2. Directory Segment (Grey)
    _draw_segment $grey $white "$icon_dir"(prompt_pwd)
    set_color $grey

    # 3. Git Segment (Purple - only if in git repo)
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l branch (git branch --show-current)
        set_color -b $purple
        echo -n "$separator"
        _draw_segment $purple $black "$icon_git$branch"
        set_color $purple
    end

    # 4. Status Indicator (Red if error)
    if test $last_status -ne 0
        set_color -b $red
        echo -n "$separator"
        _draw_segment $red $black " $last_status"
        set_color $red
    end

    # End of prompt
    set_color -b normal
    echo -n "$separator "
    set_color normal
end
