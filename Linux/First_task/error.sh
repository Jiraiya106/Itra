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
    std >& std.log
    err >&2
    echo "34"
}

YOU=$(main 2>&1 | tee >(wc -l) > /dev/null)
echo "YOU: $YOU"
main 2> /dev/null