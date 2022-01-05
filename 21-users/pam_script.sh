#!/bin/bash

if [[ `id -Gn "$PAM_USER" | grep -c "admin"` = 1 ]] || [[ `date +%u` < 6 ]]
then
exit 0
else
exit 1
fi
