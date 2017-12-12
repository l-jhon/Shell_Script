#!/bin/bash

# Deletando Arquivos que não foram modificados nos últimos 5 dias

PATH=/nl/nfe_prod/danfe/
FIND=/bin/find
RM=/bin/rm

for I in $($FIND $PATH -name *.pdf -mtime +5 -type f);
	do
    	$RM -f $I 
	done


