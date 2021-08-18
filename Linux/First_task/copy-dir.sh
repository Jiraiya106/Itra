#!/bin/bash

SOURCE_DIR=$(realpath "$1")
DESTINATION_DIR=$(realpath "$2")
DATE_FORMAT=$(date +%Y%m%d_%H%S)

the_same_names () {
	if [ "$1" == "$2" ]
	then
		echo "The same names"
		exit 0
	fi
} 

#Free disk
get_free_disk_space () {
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
get_dir_space () {
  du -s "$1" | awk '{print$1}'
}

#Copy direct
copyall () {
  cp -p -r $1 $2
}

copy_archive () {
	while true;do
		echo "We use the date(D) or rotation(R)?"
		read -p "" answer
		case $answer in 
			D | d) 
				$(tar -czpf $DESTINATION_DIR/$DATE_FORMAT.tar.gz $SOURCE_DIR >& /dev/null)
				break 2;;
			R | r)
				echo "Maximum number of copies " 
				read -p "" copies
				arr=(${DESTINATION_DIR}/[0-9].tar.gz)
				for ((a=${#arr[*]}; a >= $copies; a--)) do
				rm -f $DESTINATION_DIR/$a.tar.gz
				done
				for ((a=${#arr[*]}; a > "0"; a--)) do
					$(mv ${arr[$a-1]} $DESTINATION_DIR/$a.tar.gz >& /dev/null)
					rm -f $DESTINATION_DIR/$copies.tar.gz
				done
				$(tar -czpf $DESTINATION_DIR/0.tar.gz -P $SOURCE_DIR >& /dev/null)

				break 2;;
			*) echo "Try again";;
		esac
	done
}

copyfile () {
	FREE_DISK_DEST=$(get_free_disk_space $2)
	DIR_SPACE_SOURCE=$(get_dir_space $1)

	if [ "$DIR_SPACE_SOURCE" -lt "$FREE_DISK_DEST" ] 
	then
		copy_archive
	else
		while true; do
			read -p "Not enough no free space disk. Continue?(Y/N)" answer
			case "$answer" in
				Y | y) 
					copy_archive
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
  the_same_names "$SOURCE_DIR" "$DESTINATION_DIR"
  directoryproblem "$SOURCE_DIR" "$DESTINATION_DIR"
	copy_archive
}

main
