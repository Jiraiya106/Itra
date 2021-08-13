#!/bin/bash
defarg () {
arr=( $1 )
for i in "${arr[@]}"
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
    -h|--help)
    helping
    exit 0 # past argument=value
    ;;
    *)
      if [ -z "$DIRECTORY" ]
      then
        DIRECTORY="${i#*=}"
        shift # past argument=value
      fi
    ;;
esac
done
}

helping () {
  echo "random-structure.sh [ARGUMENTS...]"
  echo "-d= --directory= - директория"
  echo "-n= --nested-depth= - глубина вложенности"
  echo "-s= --min-size= - минимумальный размер"
  echo "-S= --max-size= - максимальный размер"
  echo "-i= --max-iteration= - максимальное количество итераций"
  echo "-l= --min-length= - минимальная длина названия"
  echo "-L= --max-length= - максимальная длина названия"
  echo "-f= --file-content= - чем наполнить"
  echo "-r --random - рандомное наполнение"
  echo "-h --help - помощь"

}

# Функция определения длинны и веса
func_max_min(){
    numberminmax=$(shuf -i $1-$2 -n 1)
}

#Функция определения "file" или "directory" и имени
file_directory () {
  BINARY=2
  number=$RANDOM
  T=1
  func_max_min $MIN_LENGTH $MAX_LENGTH
  LENGTH=$numberminmax

  name=$(head -c $(($MAX_LENGTH*2)) /dev/urandom | base64 | sed 's/[+=/A-Z]//g' | tr -d '\n' | tail -c "$LENGTH")
  #echo "Name: $name"
  (( number %= $BINARY ))

  if [ "$number" -eq $T ]
    then
      DO_IT="file"
  else
      DO_IT="directory"
  fi
}

choicedir(){
    r=$(shuf -i 1-${#DIRARR[@]} -n 1)
    SELECTDIR=${DIRARR[$r-1]}
}

# Генерация случайных "file" или "directory" .
filedir () {
counter=1
for ((a=1; a <= MAX_ITERATION ; a++))  
do
  file_directory

  if [ "$DO_IT" = "file" ]
  then
      func_max_min $MIN_SIZE $MAX_SIZE
      SIZE=$numberminmax
      choicedir
      file_content
  else
      
      if [ "$counter" -le "$NESTED_DEPTH" ]
      then
        
        mkdir -p $DIRECTORY/$name
        DIRECTORY="${DIRECTORY}/${name}/"
        ((counter++))
      else
        choicedir
        mkdir -p $SELECTDIR/$name 
        DIRARR+=("$SELECTDIR/$name")
      fi
  fi
done 
}

file_content () {
  #echo "Direcrory: $DIRECTORY  name: ${name}"
  < /dev/urandom tr -dc $FILE_CONTENT | head -c${SIZE} > "$DIRECTORY"/"${name}".txt
}

main () {

  defarg "$(echo ${@})"

  if [ -z "$DIRECTORY" ]
    then
      DIRECTORY="$PWD/random_file"
  fi
  mkdir -p "$DIRECTORY"
  DIRARR+=("$DIRECTORY")

  filedir
}

main "$@"