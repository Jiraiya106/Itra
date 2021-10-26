#!/bin/bash

SOURCE_DIR=$(realpath "$1")
DESTINATION_DIR=$(realpath "$2")
DATE_FORMAT=$(date +%Y%m%d_%H%S)

compare_dir_paths () {
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

is_directory_parentine () {
  PARENT_SOURCE=$(dirname "$1")
  PARENT_DESTINATION=$(dirname "$2")

  if [ "$1" == "$PARENT_DESTINATION" ]
  then
    echo ""$2" parent directory "$1""
    exit 0
  elif [ "$2" == "$PARENT_SOURCE" ]
  then 
    echo ""$1" parent directory "$2""
    exit 0
  fi
}

#Volume directory
get_dir_space () {
  du -s "$1" | awk '{print$1}'
}

archive_and_cleanup () {
  case $choice_d_or_r in 
    D | d)
      tar  -czpf $DESTINATION_DIR/$DATE_FORMAT.tar.gz  -C $PARENT_SOURCE $(basename $SOURCE_DIR) 1>& out_$DATE_FORMAT.log
      ;;
    R | r)
      arr=(${DESTINATION_DIR}/[0-9].tar.gz)
      for ((a=${#arr[*]}; a >= $copies; a--)) do
        rm $DESTINATION_DIR/$a.tar.gz 1>& out_$DATE_FORMAT.log
      done
      for ((a=${#arr[*]}; a > "0"; a--)) do
        $(mv ${arr[$a-1]} $DESTINATION_DIR/$a.tar.gz 1>& out_$DATE_FORMAT.log)
        rm $DESTINATION_DIR/$copies.tar.gz 1>& out_$DATE_FORMAT.log
      done
      $(tar -czpf $DESTINATION_DIR/0.tar.gz -P -C $PARENT_SOURCE $(basename $SOURCE_DIR) 1>& out_$DATE_FORMAT.log)
      ;;
    *) echo "Try again";;
  esac
}

file_archiving () {
  DEST_FREE_DISK=$(get_free_disk_space $2)
  SOURCE_DIR_SIZE=$(get_dir_space $1)

  if [ "$SOURCE_DIR_SIZE" -lt "$DEST_FREE_DISK" ] 
  then
    archive_and_cleanup
    NUMBER_ERROR=$(archive_and_cleanup 2>&1 | tee >(wc -l) > /dev/null) && cat out_$DATE_FORMAT.log
  else
    while true; do
      read -p "Not enough no free space disk. Continue?(Y/N)" choice_y_or_n
      case "$choice_y_or_n" in
        Y | y) 
          NUMBER_ERROR=$(archive_and_cleanup 2>&1 | tee >(wc -l) > /dev/null) && cat out_$DATE_FORMAT.log
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
  compare_dir_paths "$SOURCE_DIR" "$DESTINATION_DIR"
  is_directory_parentine "$SOURCE_DIR" "$DESTINATION_DIR"
  
  while true;do
    echo "We use the date(D) or rotation(R)?"
    read -p "" choice_d_or_r
      case $choice_d_or_r in 
        D | d) 
          choice_d_or_r=D
          break 2;;
        R | r) 
          choice_d_or_r=R
          echo "Maximum number of copies "
          read -p "" copies 
          break 2;;
        *) echo "Try again";;
      esac
  done
  
  file_archiving "$SOURCE_DIR" "$DESTINATION_DIR"
  find out_*.log -type f -empty -exec rm {} \;
  if [ $NUMBER_ERROR -ne 0 ] 
  then
    echo -e "\033[31mWarning: $NUMBER_ERROR error(s) occurred!"
  fi
}


main