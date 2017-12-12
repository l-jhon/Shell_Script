#!/bin/bash

# Author: Jhon Lucas

#Set Variable
echo=/bin/echo
cat=/bin/cat
ssh=/usr/bin/ssh
scp=/usr/bin/scp
rm=/bin/rm
chmod=/bin/chmod
chown=/bin/chown
whoami=`/usr/bin/whoami`
PATH=/scripts/lista_servidores.txt

#Check if User is Root
if [ "${whoami}" != 'root' ];
        then
                $echo 'Voce precisa ser root para executar este Shell Script'
        exit 1
fi

#Using when execute without parameter
usage() {
$cat << EOF
usage: $0 -p

Este Shell Script conecta via SSH na Lista de Servidores e executa o comando passado como parâmetro em todos os Servidores.

OPTIONS:
  -p    Comando a ser executado.

EOF
}

while getopts "p:" OPTION;
    do
        case "${OPTION}" in
                p)                      V_CMD="${OPTARG}"
                                        ;;
              
                ?)                      usage
                                        exit 1
                                        ;;
        esac
    done

if [ -z "${V_CMD}" ];
        then
                usage
                exit 1
fi

for FILE in `$cat ${PATH}`;
        do
                $echo 'Servidor '${FILE}
                $ssh -p 22 root@${FILE} ${V_CMD}
        done
