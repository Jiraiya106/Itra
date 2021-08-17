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
	PARENT_SOURCE=$(dirname "$1")
	PARENT_DESTINATION=$(dirname "$2")

	if [ "$1" == "$PARENT_DESTINATION" ]
	then
		echo ""$2" parent directory "$1""
		exit 0
	elif [ "$2" == "$PARENT_SOURCE" ]
	then 
		echo ""$1" parent directory "$2""
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
	FREE_DISK_DEST=$(freedisk $2)
	DIR_SPACE_SOURCE=$(dirspace $1)

	if [ "$DIR_SPACE_SOURCE" -lt "$FREE_DISK_DEST" ] 
	then
		copyall $1 $2 
	else
		while true; do
			read -p "Not enough no free space disk. Continue?(Y/N)" answer
			case "$answer" in
				Y | y) 
					copyall $1 $2 
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
    idenname "$SOURCE_DIR" "$DESTINATION_DIR"
    directoryproblem "$SOURCE_DIR" "$DESTINATION_DIR"
    #copyfile "$SOURCE_DIR" "$DESTINATION_DIR"
		copy_arhiv
		
}


copy_arhiv () {
	while true;do
		read -p "We use the date(D) or rotation(R)?" answer
		case $answer in 
			D | d) 
				DATE_NAME=$(date +%Y%m%d_%H%S)
				tar -czpf $DESTINATION_DIR/$DATE_NAME.tar.gz $SOURCE_DIR
				break 2;;
			R | r) 
				read -p "Maximum number of copies" copies
				for ((a=$copies; a >= "0"; a--)) do
					tar -czpf $DESTINATION_DIR/$a.tar.gz $SOURCE_DIR
					
					#$copies--
					echo "$a"
				done
				rm $DESTINATION_DIR/$copies.tar.gz
				break 2;;
			*) echo "Try again";;
		esac
	done
}

main