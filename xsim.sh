function xsim() {

    # dependency
    if [[ -z $(command -v fzf) ]]; then
        brew install fzf
    fi

    # help + doc
    if [[ "$@" =~ "--help" ]] || [[ $# -eq 0 ]]; then
        local __doc__="
        Xcode simulator helper

        Usage:  xsim [command]
              * xsim open
              * xsim kill
              * xsim restart
                xsim boot [search?]
                xsim ls
                xsim screenshot
                xsim booted

        Options:
            --help   show documentation

        See 'xsim --help' for more information on a specific command.
        "
        echo "$__doc__" | cut -b 9- | sed '$d' | sed '1d'
        return
    fi

    # command
    if [[ "$1" == "open" ]]; then
        open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
        return
    fi
    if [[ "$1" == "kill" ]]; then
        osascript -e 'quit app "Simulator"'
        return
    fi
    if [[ "$1" == "restart" ]]; then
        xsim kill
        sleep 0.3
        xsim open
        return
    fi
    if [[ "$1" == "booted" ]]; then
        xcrun ls
        return
    fi
    if [[ "$1" == "ls" ]]; then
        xcrun simctl list | grep -E "\((.{8}-.{4}-.{4}-.{4}-.{12})\)" | xargs -I {} echo "{}"
        return
    fi

    if [[ "$1" == "screenshot" ]]; then
        timestamp=$(date +%F+%T)
        outpath="./screenshot-$timestamp.png"
        xcrun simctl io booted screenshot --type=png --mask=black "$outpath"
        return
    fi

    if [[ "$1" == "boot" ]]; then
        if [[ $# -gt 1 ]]; then
            device=$(xsim ls | grep -i "$2" | head -1)
            echo "$device"
        else
            device=$(xsim ls | fzf)
            echo "$device"
        fi

        if [[ -z "$device" ]]; then
            echo "Device not found"
            exit 1
        fi

        if [[ "$device" =~ "(Booted)" ]]; then
            echo "Device already booted"
            return
        fi

        uuid=$(echo "$device" | grep -E ".{8}-.{4}-.{4}-.{4}-.{12}" -o)
        echo "Boot UUID $uuid"
        xcrun simctl boot $uuid
        echo "Done"

    fi

    echo "command not found"
    exit 1
}
