#!/bin/bash
DIRECTORY=$1
NESTED_DEPTH=$2
MIN_SIZE=$3
MAX_SIZE=$4
MAX_ITERATION=$5
MIN_LENGTH=$6
MAX_LENGTH=$7

for i in "$@"
do
case $i in
    -d=*|--directory=*)
    DIRECTORY="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--nested-depth=*)
    NESTED_DEPTH="${i#*=}"
    shift # past argument=value
    ;;
    -s=*|--min-size=*)
    MIN_SIZE="${i#*=}"
    shift # past argument=value
    ;;
    -S=*|--max-size=*)
    MAX_SIZE="${i#*=}"
    shift # past argument=value
    ;;
    -i=*|--max-iteration=*)
    MAX_ITERATION="${i#*=}"
    shift # past argument=value
    ;;
    -l=*|--min-length=*)
    MIN_LENGTH="${i#*=}"
    shift # past argument=value
    ;;
    -L=*|--max-length=*)
    MAX_LENGTH="${i#*=}"
    shift # past argument=value
    ;;
    -f=*|--file-content=*)
    FILE_CONTENT="${i#*=}"
    shift # past argument=value
    ;;
    -r|--random)
    FILE_CONTENT="[:print:]"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

echo $DIRECTORY $NESTED_DEPTH $MIN_SIZE $MAX_SIZE $MIN_LENGTH $MAX_LENGTH $MAX_ITERATION

# while [[ $# -gt 0 ]]
# do
# key="$1"

# case $key in
#     -d|--directory)
#     DIRECTORY="$2"
#     shift # past argument
#     shift # past value
#     ;;
#     -n|--nested-depth)
#     NESTED_DEPTH="$2"
#     shift # past argument
#     shift # past value
#     ;;
#     -s|--min-size)
#     MIN_SIZE="$2"
#     shift # past argument
#     shift # past value
#     ;;
#     -S|--max-size)
#     MAX_SIZE="$2"
#     shift # past argument
#     shift # past value
#     ;;
#     -i|--max-iteration)
#     MAX_ITERATION="$2"
#     shift # past argument
#     shift # past value
#     ;;
#     -l|--min-length)
#     MIN_LENGTH="$2"
#     shift # past argument
#     shift # past value
#     ;;
#     -L|--max-length)
#     MAX_LENGTH="$2"
#     shift # past argument
#     shift # past value
#     ;;
#     -f|--file-content)
#     FILE_CONTENT="$2"
#     shift # past argument
#     shift # past value
#     ;;
#     -r|--random)
#     FILE_CONTENT="[:print:]"
#     shift # past argument
#     shift # past value
#     ;;     
#     *)    # unknown option
#     POSITIONAL+=("$1") # save it in an array for later
#     shift # past argument
#     ;;
# esac
# done

# if [[ ! -e $DIRECTORY ]]; then
    
#     mkdir $DIRECTORY
# fi

mkdir -p $DIRECTORY
echo ${POSITIONAL[*]}

# Функция определения длинны и веса
func_max_min(){
    number=$(shuf -i $1-$2 -n 1)
}

#Функция определения "file" или "directory" и имени
file_directory () {
  BINARY=2
  number=$RANDOM
  T=1
  func_max_min $MIN_LENGTH $MAX_LENGTH
    LENGTH=$number
    # echo "Length: $LENGTH"

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
for ((a=1; a <= MAX_ITERATION ; a++))  
do
  file_directory

  if [ "$DO_IT" = "file" ]
  then
      func_max_min $MIN_SIZE $MAX_SIZE
      SIZE=$number
      # echo "Size: $SIZE"

      < /dev/urandom tr -dc $FILE_CONTENT | head -c${SIZE} > $DIRECTORY/${name}.txt
      echo $DO_IT $name
  else
      
      if [ "$counter" -le "$NESTED_DEPTH" ]
      then
        DIRARR+=("$DIRECTORY")
        mkdir $DIRECTORY/$name
        DIRECTORY="${DIRECTORY}${name}/"
        echo $DO_IT $name $counter $NESTED_DEPTH 
        echo ${DIRARR[*]}
        ((counter++))
      else
        r=$(shuf -i 1-${#DIRARR[@]} -n 1)
        SELECTDIR=${DIRARR[$r-1]}
        mkdir $SELECTDIR/$name 
        echo "i am"
      fi
  fi

done 

