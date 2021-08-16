#!/bin/bash

SOURCE_DIR=$(realpath "$1")
DESTINATION_DIR=$(realpath "$2")

echo $SOURCE_DIR $DESTINATION_DIR

if [ "$SOURCE_DIR" == "$DESTINATION_DIR" ]
then
    echo "ERROR 1"
    #exit 0
fi

#Свободное место на диске
freedisk () {
    FREEDISK=$(df "$1" | tail -1 | awk '{print$4}')
}

parentdir () {
    PARENT_DIR=$(dirname $1)
}

parentdir $SOURCE_DIR
PARENT_SOURCE=$PARENT_DIR
parentdir $DESTINATION_DIR
PARENT_DEST=$PARENT_DIR

echo $PARENT_SOURCE $PARENT_DEST

# if [ "$SOURCE_DIR" == "$PARENT_DEST" ]
# then
#     echo "ERROR 2"
#     #exit 0
# elif [ "$DESTINATION_DIR" == "$PARENT_SOURCE" ]
# then 
#     echo "ERROR 3"
# fi

 #Объем папки
DIRSPACE=$(du -s "$SOURCE_DIR" | awk '{print$1}')

freedisk $DESTINATION_DIR

#Скопировать папки
copyall () {
    cp -p -r $1 $2
}

copyfile () {
if [ "$DIRSPACE" -lt "$FREEDISK" ]
then
    copyall $SOURCE_DIR $PARENT_DEST 
else 
    echo "Not enough free space no disk. Continue?(Y/N)"
    read
    case "$1" in
    "Y" | "y") 
        copyall $SOURCE_DIR $PARENT_DEST;;
    "N" | "n") 
        exit 0;;
    *)
        copyfile
    esac
fi
}
echo $DIRSPACE $FREEDISK





MOUNTDISK=$(df /home/ITRANSITION.CORP/e.ilin/Work/Itra/ | tail -1 | awk '{print$1}') #Куда смонтирована
