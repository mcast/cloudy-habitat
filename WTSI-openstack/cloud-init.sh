#!/bin/sh

set -e

printf "here: in \$0=%s at PWD=%s with SHLVL=%s as user=%s\n" "$0" "$( pwd )" "$SHLVL" "$( whoami )"

if [ $( ls -1 /home | wc -l ) != 1 ]; then
    echo Cannot guess my less-privileged user name from /home contents
    exit 1
fi

fetch_proj() {
    luser=$( ls -1 /home | head -n1 )
    echo Seeing one less-privileged user named $luser

    su -c '
 echo here in $PWD at $( date ) as $( whoami )
 cd
 [ -d cloudy-habitat ] || git clone https://github.com/mcast/cloudy-habitat
' $luser
}

fetch_proj

# replace the default user
/home/$luser/cloudy-habitat/part/user-security.sh --destroy-luser-and-homedir $luser

# fetch again, we destroyed the previous copy
fetch_proj
