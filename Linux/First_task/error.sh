#!/bin/bash

std () {
    echo "messages1"
    echo "messages2"
}

err () {
    echo "error1"
    echo "error2"
}

main () {
    exec 3>std.log
    std >&3
    err >&2
    read -p "123" cop
    echo "$cop"
}

main 2>&2 | tee >(wc -l) > dev/null
echo "YOU: $YOU"
#main 2> /dev/null