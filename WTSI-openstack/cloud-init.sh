#!/bin/sh

if [ $( ls -1 /home | wc -l ) != 1 ]; then
    echo Cannot guess my less-privileged user name from /home contents
    exit 1
fi

luser=$( ls -1 /home | head -n1 )
echo Seeing one less-privileged user named $luser

su -c '
 echo here in $PWD at $( date ) as $( whoami )
 cd
 git clone https://github.com/mcast/cloudy-habitat
' $luser
