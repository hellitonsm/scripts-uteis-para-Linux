#!/bin/bash

#Passo 1: Criar arquivo temporário
#Passo 2: Converter JPEG para Texto.
#Passo 3: Pesquisar se no arquivo tem o texto do csv
#Passo 4: Endireitar o texto
#Passo 5: Converter para pdf pesquisavel
#Passo 6: Salvar com o novo nome

#variaveis

INPUT=data.csv
IFS=,


#Passo1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
WORK_DIR=`mktemp -d -p "$DIR"`
if [[ ! "$WORK_DIR"  || ! -d "$WORK_DIR" ]]; then
    echo "Não foi criado o diretório temporario"
    exit 1
fi

function cleanup {
    rm -rf "$WORK_DIR"
    echo "Diretório temporário está sendo deletado: $WORK_DIR"
}

trap cleanup EXIT

#echo "cat out | grep -o  \"\<[[:upper:]][[:upper:]]*\>\"" >../somentemaisculo
#tesseract "Alaf dos Santos Moreira.jpeg" stdout -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ%/-15 > out
# cut -d'.' -f1

#Passo2

for i in jpeg/*.jpeg jpeg/*.jpg
do
   #tesseract "$i" stdout -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ%/-15 > "$WORK_DIR/$(basename -- $i)"
   #echo "$WORK_DIR/${i%.*}.txt"
   #tesseract "$i" stdout -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ%/-15 >> "$WORK_DIR/${i%.*}.txt" 
   #r="${i##*/}"
   #echo ${r%.*}
   tesseract "$i" stdout -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ%/-15 > "$WORK_DIR/${i##*/}.txt"
   #echo "ola" > "$WORK_DIR/$
done

#for i in $WORK_DIR/*.txt
#do
    #cat "$i" | sed 's/\n/\ /g'
#    cat "$i" | tr "\n" " " >> "$i"
#done

#Passo3
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read col1
do 
    for i in $WORK_DIR/*.txt
    do
        string=`cat "$i" | tr "\n" " "`
        #echo $string
        #echo $col1
        cola=`echo $col1 | sed 's/\\r//g'`
        if [[ $string == *"$cola"* ]]; then
            #echo $i
            #dir1="${i##*/}"
            #dir2="jpeg/${dir1%.*}."
            #dir3="resultado/$cola.pdf"
            #echo $dir2
            #echo $dir3
            dir1="${i%.txt}"
            dir2="jpeg/${dir1##*/}"
            #echo $dir2
            rm $i
            #passo4
            convert "$dir2" -deskew 40% "$WORK_DIR/$(basename -- $dir2)"
            #echo "$dir1"
            #passo5
            tesseract "$dir1" "$dir1" -l por --psm 1 pdf
            #dir3=
            #passo6
            cp "$dir1.pdf" "resultado/$cola.pdf"
        fi
    done
done < $INPUT
