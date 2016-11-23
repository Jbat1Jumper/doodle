#!/usr/bin/env bash

fiddle () {
    s1="\e[0m"
    s2="\e[4m"
    case $1 in
    help)
        echo "${s1}Fiddle commands:"
        echo "$(
        echo " - today|now [description] - Creates a new fiddle for today or jumps to"
        echo " - - it if there is one created"
        echo " - yesterday - Jumps to the fiddle for yesterday"
        echo " - last - Jumpst to the last fiddle created"
        echo " - at <name> - Jumps to the fiddle with the given name"
        echo " - prev/next - Jumps to previous or next fiddle"
        echo " - another [description] - If theres a fiddle for today, this creates"
        echo " - - a new one with a suffix"
        echo " - create <name> [description] - Creates a new fiddle with given name"
        echo " - desc|describe [description] - Changes the current fiddle description"
        echo " - is - Prints yes/no if you are inside a fiddle folder"
        echo " - root - Prints the root directory for the current fiddle"
        echo " - help - Prints this help"
        )" | column -s- -t
        echo "Also use 'fiddles' to list all the current fiddles"
        ;;
    last)
        last=`ls -1 ~/Fiddles | tail -n 1`
        fiddle at $last
        ;;
    yesterday)
        yesterday=$(date -v-1d +"%Y-%m-%d")
        fiddle at $yesterday
        ;;
    today|now)
        today=$(date +"%Y-%m-%d")
        if [ -d ~/Fiddles/$today ]; then
            if [ "$2" ]; then
                echo "There is a fiddle created today"
                echo "Use 'fiddle another \"$2\"' to create other fiddle"
            fi
            fiddle at $today
        else
            fiddle create $today "$2"
        fi
        ;;
    at*)
        if [ -d ~/Fiddles/$2 ]; then
            cd ~/Fiddles/$2
            echo "${s1}Switching to: ${s2}$(cat .fiddle)"
        else
            echo "${s1}No such fiddle"
        fi
        ;;
    prev)
        if [ "$(fiddle is)" = "yes" ]; then
            root=$(fiddle root)
            name=$(basename $root)
            prev=$(ls -1 $root/.. | grep -B 10000 $name\$ | tail -n 2 | head -n 1)
            fiddle at $prev
        else
            echo "${1}No fiddle here"
        fi
        ;;
    next)
        if [ "$(fiddle is)" = "yes" ]; then
            root=$(fiddle root)
            name=$(basename $root)
            next=$(ls -1 $root/.. | grep -A 1000 $name\$ | head -n 2 | tail -n 1)
            fiddle at $next
        else
            echo "${1}No fiddle here"
        fi
        ;;
    describe|desc)
        if [ "$(fiddle is)" = "yes" ]; then
            root=$(fiddle root)
            if [ "$2" ]; then
                echo "$2" > $root/.fiddle
            else
                echo "${s1}Description: ${s2}$(cat $root/.fiddle)"
            fi
        else
            echo "${s1}No fiddle here"
        fi
        ;;
    create)
        if [ "$2" ]; then
            if [ ! -d ~/Fiddles/$2 ]; then
                mkdir -p ~/Fiddles/$2
                cd ~/Fiddles/$2
                : ${3:="Empty fiddle"}
                echo "$3" > .fiddle
                touch .gitignore
                echo "${s1}Creating: ${s2}$(cat .fiddle)"
                git init -q
                git add .fiddle .gitignore
                git commit -q -m "Fiddle initial commit"
            fi
        else
            echo "${s1}No fiddle name profided"
        fi
        ;;
    another)
        today=$(date +"%Y-%m-%d")
        for i in $(seq 98 112); do
            c=$(printf \\$(printf '%03o' $i))
            if [ ! -e ~/Fiddles/$today$c ]; then
                fiddle create $today$c "$2"
                break
            fi
        done
        ;;
    is)
        if git rev-parse --git-dir > /dev/null 2>&1; then
            root=$(fiddle root)
            if [ -e $root/.fiddle ]; then
                echo "yes"
            else
                echo "no"
            fi
        else
            echo "no"
        fi
        ;;
    root)
        echo "$(git rev-parse --show-toplevel)"
        ;;
    *)
        if [ "$(fiddle is)" = "yes" ]; then
            fiddle describe
        else
            echo "Use 'fiddle today [description]' to create a new fiddle"
            echo "Or 'fiddle help' for more commands"
        fi
        ;;
    esac
}

fiddles () {
    s1="\e[0m"
    s2="\e[4m"
    rows=""
    for f in $(ls ~/Fiddles); do
        if [ "$(cd ~/Fiddles/$f && fiddle is)" = "yes" ]; then
            rows=$rows"${s1}$f:¶${s2}$(cat ~/Fiddles/$f/.fiddle)\\n"
        else
            rows=$rows"${s1}$f:¶${s2}...\\n"
        fi
    done
    printf "$rows" | column -s¶ -t
}

