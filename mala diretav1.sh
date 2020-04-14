#!/bin/bash

#Para usar é necessário três arquivos.
#Uma Pasta resultado
#Um arquivo docx
#um arquivo csv

IFS=,
sp="/-||"
sc=0
spin(){
    printf "\b${sp:sc++:1}"
    ((sc==${#sp})) && sc=0
}
endspin(){
    printf "\r%s\n" "$@"
}

#Aqui é o nome do docx
FILE='Todos.docx'    

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

DIR=$PWD
  
mkdir $WORK_DIR/resultado
#O nome do arquivo CSV
INPUT=MAPA.csv

[ ! -f $INPUT ] && { echo "$INPUT arquivo não encontrado"; exit 99; }
#é necessário verificar e modificar a ordem a depender da ordem que está na tabela
while read sala periodo pai mae
do 
    spin
    cp $FILE $WORK_DIR
    mkdir $WORK_DIR/tmp
    unzip $FILE -d $WORK_DIR/tmp >/dev/null
    rm $WORK_DIR/$FILE
#No arquivo é necessário ter <> e no caso ser diferente da ordem aqui é necessário modificar
    sed -e "s/&lt;SALA&gt;/${sala}/" -e "s/&lt;PERIODO&gt;/${periodo}/"\
    -e "s/&lt;PAI&gt;/${pai}/"\
    -e "s/&lt;MAE&gt;/${mae}/" -i $WORK_DIR/tmp/word/document.xml
    cd $WORK_DIR/tmp
    zip -r ${FILE} * >/dev/null
    #echo $DIR
    cd $DIR
    cp $WORK_DIR/tmp/${FILE} $WORK_DIR/resultado/
    mv $WORK_DIR/resultado/${FILE} $DIR/resultado/"${nome}.docx"
    cp $FILE $WORK_DIR
    rm -rf $WORK_DIR/tmp
done < $INPUT
endspin

