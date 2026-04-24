#!/bin/bash

function __print_frame {
    local frame_length=$(($(tput cols) / 2))
    for ((i=0; i < $frame_length; i++))
    do
        printf "─ "
    done

    printf "\n"
}

function run_cmd {
    local cmd="$1"
    local msg="$2"
    
    __print_frame
    printf "Next Command:\n\e[1m$cmd\e[0m\n(Press <enter> to execute)\n"
    read -s

    $cmd

    printf "\n\n"
    if [[ -n "$msg" ]]
    then
        printf "🟡 $msg\n\n"
    fi
}

function run_cmd_on_new_shell {
    local cmd="$1"
    local msg="$2"
    local resultvar="$3"

    __print_frame
    printf "Next Command (new shell):\n\e[1m$cmd\e[0m\n(Press <enter> to execute)\n"
    read -s

    local pipe_for_pid=$(mktemp -u)
    mkfifo "$pipe_for_pid"

    gnome-terminal -- bash -c "
        $cmd &
        printf \"\$!\" > $pipe_for_pid
        wait
    "

    printf "\n\n"
    if [[ -n "$msg" ]]
    then
        printf "🟡 $msg\n\n"
    fi

    read pid < "$pipe_for_pid"
    rm "$pipe_for_pid"

    eval "$resultvar=$pid"
}