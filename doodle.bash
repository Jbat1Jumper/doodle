#!/usr/bin/env bash

doodle () {
    s1="\e[0m"
    s2="\e[4m"
    case $1 in
    help)
        echo "${s1}Doodle: ${s2}A tool to manage code doodles"
        echo "${s1}Available commands:"
        echo "$(
        echo " - today|now [description] - Creates a new doodle for today or jumps to"
        echo " - - it if there is one created"
        echo " - yesterday - Jumps to the doodle for yesterday"
        echo " - last - Jumpst to the last doodle created"
        echo " - at <name> - Jumps to the doodle with the given name"
        echo " - prev/next - Jumps to previous or next doodle"
        echo " - another [description] - If theres a doodle for today, this creates"
        echo " - - a new one with a suffix"
        echo " - create <name> [description] - Creates a new doodle with given name"
        echo " - desc|describe [description] - Changes the current doodle description"
        echo " - is - Prints yes/no if you are inside a doodle folder"
        echo " - root - Prints the root directory for the current doodle"
        echo " - help - Prints this help"
        )" | column -s- -t
        echo "Also use 'doodles' to list all the current doodle"
        ;;
    last)
        last=`ls -1 ~/Doodles | tail -n 1`
        doodle at $last
        ;;
    yesterday)
        yesterday=$(date -v-1d +"%Y-%m-%d")
        doodle at $yesterday
        ;;
    today|now)
        today=$(date +"%Y-%m-%d")
        if [ -d ~/Doodles/$today ]; then
            if [ "$2" ]; then
                echo "There is a doodle created today"
                echo "Use 'doodle another \"$2\"' to create other doodle"
            fi
            doodle at $today
        else
            doodle create $today "$2"
        fi
        ;;
    at*)
        if [ -d ~/Doodles/$2 ]; then
            cd ~/Doodles/$2
            echo "${s1}Switching to: ${s2}$(cat .doodle)"
        else
            echo "${s1}No such doodle"
        fi
        ;;
    prev)
        if [ "$(doodle is)" = "yes" ]; then
            root=$(doodle root)
            name=$(basename $root)
            prev=$(ls -1 $root/.. | grep -B 10000 $name\$ | tail -n 2 | head -n 1)
            doodle at $prev
        else
            echo "${1}No doodle here"
        fi
        ;;
    next)
        if [ "$(doodle is)" = "yes" ]; then
            root=$(doodle root)
            name=$(basename $root)
            next=$(ls -1 $root/.. | grep -A 1000 $name\$ | head -n 2 | tail -n 1)
        doodle at $next
        else
            echo "${1}No doodle here"
        fi
        ;;
    describe|desc)
        if [ "$(doodle is)" = "yes" ]; then
            root=$(doodle root)
            if [ "$2" ]; then
                echo "$2" > $root/.doodle
            else
                echo "${s1}Description: ${s2}$(cat $root/.doodle)"
            fi
        else
            echo "${s1}No doodle here"
        fi
        ;;
    create)
        if [ "$2" ]; then
            if [ ! -d ~/Doodles/$2 ]; then
                mkdir -p ~/Doodles/$2
                cd ~/Doodles/$2
                : ${3:="Empty doodle"}
                echo "$3" > .doodle
                touch .gitignore
                echo "${s1}Creating: ${s2}$(cat .doodle)"
                git init -q
                git add .doodle .gitignore
                git commit -q -m "Doodle initial commit"
            fi
        else
            echo "${s1}No doodle name profided"
        fi
        ;;
    another)
        today=$(date +"%Y-%m-%d")
        for i in $(seq 98 112); do
            c=$(printf \\$(printf '%03o' $i))
            if [ ! -e ~/Doodles/$today$c ]; then
                doodle create $today$c "$2"
                break
            fi
        done
        ;;
    is)
        if git rev-parse --git-dir > /dev/null 2>&1; then
            root=$(doodle root)
            if [ -e $root/.doodle ]; then
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
        if [ "$(doodle is)" = "yes" ]; then
            doodle describe
        else
            echo "Use 'doodle today [description]' to create a new doodle"
            echo "Or 'doodle help' for more commands"
        fi
        ;;
    esac
}

doodles () {
    s1="\e[0m"
    s2="\e[4m"
    mkdir -p ~/Doodles
    rows=""
    for f in $(ls ~/Doodles); do
        if [ "$(cd ~/Doodles/$f && doodle is)" = "yes" ]; then
            rows=$rows"${s1}$f:¶${s2}$(cat ~/Doodles/$f/.doodle)\\n"
        else
            rows=$rows"${s1}$f:¶${s2}...\\n"
        fi
    done
    if [ "$rows" ]; then
        printf "$rows" | column -s¶ -t
    else
        echo "No doodles yet, use 'doodle now' to fix the situation!"
    fi
}

