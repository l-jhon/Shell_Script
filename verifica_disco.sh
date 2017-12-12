#!/bin/bash

# Author: Jhon Lucas

# Script para verificação de Discos

#Limpa o arquivo
echo '' > /root/check_disk.txt

#Set Variable
ECHO=/bin/echo
CAT=/bin/cat
WHOAMI=`/usr/bin/whoami`
SSH=/usr/bin/ssh
SEND='/scripts/sendEmail'
RM=/bin/rm 	
PATH=/scripts/list_servers_check.txt
GERA_LISTA_PARTICOES="df -h -P |grep -v 'Use' > /root/lista_percent.txt"
GERA_LISTA_PERCENT="cat /root/lista_percent.txt"


#Check if User is Root
if [ "${WHOAMI}" != 'root' ];
	then
		$echo 'Voce precisa ser root para executar este Shell Script'
	exit 1
fi

#Conecta em todos servidores via ssh e cria um arquivo com percentual de disco
for FILE1 in `$CAT ${PATH}`;
	do
		if [ "$FILE1" == "0.0.0.0" ]; then
	   		$SSH -p 31 root@${FILE1} ${GERA_LISTA_PARTICOES}
	   	else
	   		$SSH -p 16 root@${FILE1} ${GERA_LISTA_PARTICOES}
	   	fi
	done

for FILE2 in `$CAT ${PATH}`;
	do
		if [ "$FILE2" == "0.0.0.0" ]; then
			$SSH -p 31 root@${FILE2} ${GERA_LISTA_PERCENT} > /root/temp.txt
			$ECHO 'Servidor: '${FILE2} >> /root/check_disk.txt
			LIST_PERCENT=/root/temp.txt
		else
			$SSH -p 16 root@${FILE2} ${GERA_LISTA_PERCENT} > /root/temp.txt
			$ECHO 'Servidor: '${FILE2} >> /root/check_disk.txt
			LIST_PERCENT=/root/temp.txt
		fi

        for FILE3 in `$CAT ${LIST_PERCENT} |/bin/awk '{print $5}' |/bin/sed "s/%//g"`;
        	do
				if [ "$FILE3" -ge "95" ]; then
					VAR="true"
					break
				else
					VAR="false"
				fi
			done
                
            if [ $VAR == "true" ]; then
				$CAT /root/temp.txt >> /root/check_disk.txt
				$ECHO "" >> /root/check_disk.txt
				$RM -rf /root/temp.txt   
            else
				$ECHO '' > /root/check_disk.txt
            fi
	done

ARQ=`$CAT /root/check_disk.txt`

if [ "${ARQ}" != " " ]; 
	then
	 	SUBJECT='Monitoramento de Servidores - Espaco em Disco'
        MESSAGE='Segue em anexo relacao de servidores que estao com pouco espaco em disco, favor verificar.'
        FILE='/root/check_disk.txt'
        ${SEND} -f email@teste.com.br -t email@teste.com.br -u "${SUBJECT}" -m $MESSAGE -a $FILE -s 0.0.0.0:25 -xu @user -xp @password
	
	else
		$ECHO '' >> /dev/null
fi