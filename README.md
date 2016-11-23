# Doodle
Some shell functions for your bashrc to deal with code doodles.

## Available commands:
    today|now [description]        Creates a new doodle for today or jumps to
                                   it if there is one created
    yesterday                      Jumps to the doodle for yesterday
    last                           Jumpst to the last doodle created
    at <name>                      Jumps to the doodle with the given name
    prev/next                      Jumps to previous or next doodle
    another [description]          If theres a doodle for today, this creates
                                   a new one with a suffix
    create <name> [description]    Creates a new doodle with given name
    desc|describe [description]    Changes the current doodle description
    is                             Prints yes/no if you are inside a doodle folder
    root                           Prints the root directory for the current doodle
    help                           Prints this help

Also use 'doodles' to list all the current doodle
