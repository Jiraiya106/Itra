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
  # while true;do
  #   echo "We use the date(D) or rotation(R)?"
  #   read -p "" answer_d_or_r
    case $answer_d_or_r in 
      D | d)
        echo $SOURCE_DIR/ 
        tar  -czpf $DESTINATION_DIR/$DATE_FORMAT.tar.gz  -C $PARENT_SOURCE $(basename $SOURCE_DIR) 1>& out_$DATE_FORMAT.log
        ;;
      R | r)
        # echo "Maximum number of copies "
        # read -p "123" copies 
        arr=(${DESTINATION_DIR}/[0-9].tar.gz)
        for ((a=${#arr[*]}; a >= $copies; a--)) do
        rm -f $DESTINATION_DIR/$a.tar.gz
        err >&2
        done
        for ((a=${#arr[*]}; a > "0"; a--)) do
          $(mv ${arr[$a-1]} $DESTINATION_DIR/$a.tar.gz >& /dev/null)
          rm -f $DESTINATION_DIR/$copies.tar.gz
        done
        $(tar -czpf $DESTINATION_DIR/0.tar.gz -P -C $PARENT_SOURCE $(basename $SOURCE_DIR) >& /dev/null)

        ;;
      *) echo "Try again";;
    esac
  # done
}

copyfile () {
  FREE_DISK_DEST=$(get_free_disk_space $2)
  DIR_SPACE_SOURCE=$(get_dir_space $1)

  if [ "$DIR_SPACE_SOURCE" -lt "$FREE_DISK_DEST" ] 
  then
    copy_archive
  else
    while true; do
      read -p "Not enough no free space disk. Continue?(Y/N)" answer_y_or_n
      case "$answer_y_or_n" in
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

err () {
  echo "1"
}

main () {
  the_same_names "$SOURCE_DIR" "$DESTINATION_DIR"
  directoryproblem "$SOURCE_DIR" "$DESTINATION_DIR"
  copy_archive
}

while true;do
  echo "We use the date(D) or rotation(R)?"
  read -p "" answer_d_or_r
    case $answer_d_or_r in 
      D | d) 
        answer_d_or_r=D
        break 2;;
      R | r) 
        answer_d_or_r=R
        echo "Maximum number of copies "
        read -p "" copies 
        break 2;;
      *) echo "Try again";;
    esac
done

ERROR=$(main 2>&1 | tee >(wc -l) > /dev/null) && cat out_$DATE_FORMAT.log
if [ $ERROR -ne 0 ] 
then
  echo -e "\033[31mWarning: $ERROR error(s) occurred!"
fi

#main #2> /dev/null
#main  2>&1 6>&1| tee >(wc -l) > /dev/null

