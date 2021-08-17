#!/bin/bash

SOURCE_DIR=$(realpath "$1")
DESTINATION_DIR=$(realpath "$2")

idenname () {
if [ "$1" == "$2" ]
then
    echo "The same names"
    exit 0
fi
}

#Free disk
freedisk () {
    df "$1" | tail -1 | awk '{print$4}'
}

directoryproblem () {
PARENT_SOURCE=$(dirname $SOURCE_DIR)
PARENT_DESTINATION=$(dirname $DESTINATION_DIR)

if [ "$SOURCE_DIR" == "$PARENT_DESTINATION" ]
then
    echo ""$DESTINATION_DIR" parent directory "$SOURCE_DIR""
    exit 0
elif [ "$DESTINATION_DIR" == "$PARENT_SOURCE" ]
then 
    echo ""$SOURCE_DIR" parent directory "$DESTINATION_DIR""
fi
}

 #Volume directory
dirspace () {
    du -s "$1" | awk '{print$1}'
}

#Copy direct
copyall () {
    cp -p -r $1 $2
}

copyfile () {
FREE_DISK_DEST=$(freedisk $DESTINATION_DIR)
DIR_SPACE_SOURCE=$(dirspace $SOURCE_DIR)

if [ "$DIR_SPACE_SOURCE" -lt "$FREE_DISK_DEST" ] 
then
    copyall $SOURCE_DIR $DESTINATION_DIR 
else
    while true; do
      read -p "Not enough free space no disk. Continue?(Y/N)" answer
      case "$answer" in
				Y | y) 
					copyall $SOURCE_DIR $DESTINATION_DIR 
					break 2;;
				N | n) 
					exit 0;;
				*)
					echo "Enter Y or N"
      esac
    done
fi
}

main () {
    idenname $SOURCE_DIR $DESTINATION_DIR
    directoryproblem
    copyfile
}

main