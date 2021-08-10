#!/bin/bash
DIRECTORY=$1
NESTED_DEPTH=$2
MIN_SIZE=$3
MAX_SIZE=$4
MAX_ITERATION=$5
MIN_LENGTH=$6
MAX_LENGTH=$7

# while getopts ":d:directory::nd:" opt; do
#   case $opt in
#     a) arg_1="$OPTARG"
#     ;;
#     p) p_out="$OPTARG"
#     ;;
#     \?) echo "Invalid option -$OPTARG" >&2
#     ;;
#   esac
# done

# while [ $# -gt 0 ]; do
#   case "$1" in
#     --p_out=*)
#       p_out="${1#*=}"
#       ;;
#     --arg_1=*)
#       arg_1="${1#*=}"
#       ;;
#     *)
#       printf "***************************\n"
#       printf "* Error: Invalid argument.*\n"
#       printf "***************************\n"
#       exit 1
#   esac
#   shift
# done
#    ;;
#     \?) echo "Invalid option -$OPTARG" >&2
#     ;;
#   esac
# done

# while [ $# -gt 0 ]; do
#   case "$1" in
#     --p_out=*)
#       p_out="${1#*=}"
#       ;;
#     --arg_1=*)
#       arg_1="${1#*=}"
#       ;;
#     *)
#       printf "***************************\n"
#       printf "* Error: Invalid argument.*\n"
#       printf "***************************\n"
#       exit 1
#   esac
#   shift
# done

# Эти два способа могут быть скомбинированы.
func_max_min(){
number=0   #initialize
while [ "$number" -le $1 ]
do
  number=$RANDOM
  let "number %= $2"  # Ограничение "сверху" числом $RANGE.
done
}

func_max_min $MIN_LENGTH $MAX_LENGTH
LENGTH=$number
echo "Length: $LENGTH"

func_max_min $MIN_SIZE $MAX_SIZE
SIZE=$number
echo "Size: $SIZE"

file_directory () {
BINARY=2
number=$RANDOM
T=1
name=$(head -c 100 /dev/urandom | base64 | sed 's/[+=/A-Z]//g' | tail -c "$LENGTH")

let "number %= $BINARY"

if [ "$number" -eq $T ]
then
  DO_IT=file
else
  DO_IT=directory
fi
}


# Генерация случайных "file" или "directory" .
counter=1
for ((a=1; a <= MAX_ITERATION ; a++))  # Двойные круглые скобки и "LIMIT" без "$".
do
  file_directory

  if [ "$DO_IT" = "file" ]
  then
      #dd if=/dev/urandom of=${name}.txt bs=${SIZE}M count=1 iflag=fullblock
      #$(head -c ${SIZE}M </dev/urandom | sed 's/[+=/A-Z]//g' >${name}.txt)${SIZE}
      #$(head /dev/urandom | tr -dc 3 | head -c5K > ${name}.txt) 
      #$(while true;do head /dev/urandom | tr -dc 3;done | head -c5K > ${name}.txt)
      #while true;do head /dev/urandom | tr -dc A-Za-z0-9;done | head -c 5K > 
      #< /dev/urandom tr -dc "[:space:][:print:]" | head -c66 > ${name}.txt
      < /dev/urandom tr -dc "3" | head -c5K > $DIRECTORY/${name}.txt
      echo $DO_IT $name
  else
      
      if [ "$counter" -le "$NESTED_DEPTH" ]
      then
        $(mkdir $DIRECTORY/$name) 
        DIRECTORY="${DIRECTORY}/${name}"
        echo $DO_IT $name $counter $NESTED_DEPTH
        ((counter++))
      else
        mkdir $DIRECTORY/$name 
        echo "i am"
      fi
  fi

done 

echo "Случайное число в диапазоне от FLOOR до RANGE ---  $number"
echo $(head /dev/urandom | tr -dc 13 | head -c 3 ; echo '')

# Глубина вложенности
# for i in {1..100}
# do
#     mkdir subdirectory_$i
# done