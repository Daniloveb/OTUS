#!/bin/bash
marker=$1
log=$2
DATE=`date`
logger teak
if grep $marker $log &> /dev/null
then
logger "$DATE: alert " # logger отправляет лог в системный журнал (/var/log/messages)
else
exit 0
fi