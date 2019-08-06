#! /bin/sh

set -eu
unset CDPATH

case $( lsb_release -si || uname || echo unknown ) in
    Ubuntu|Debian)
	echo looks like a debian flavour
	;;
    Darwin)
	echo looks like a MacOS flavour
	echo not going to mess with that just now
	exit 1
	;;
    *)
	echo "don't know where I am, aborting"
	exit 1
	;;
esac

cd -P "$( dirname "$0" )"

if [ -f sudo-ok ]; then
    echo already marked with $PWD/sudo-ok file
else
    set -x
    pwd
    if echo sudo ok; then
	touch sudo-ok
	set +x
    else
	set +x
	echo sudo failed, try again or continue with
	echo " $PWD/start.sh"
	exit 1
    fi
fi

case $( lsb_release -si || uname || echo unknown ) in
    Ubuntu|Debian)
	# TODO: refine by lsb_release flavour and version?
	set -x
	sudo apt update
	sudo apt install aptitude
	sudo aptitude install $( grep -vE '^#' pkglist-debian.txt )
	set +x
	;;
    *)
	echo "don't know what to do on this platform"
	exit 1
	;;
esac

echo
echo proceed to next stage
set -x
exec ./start.sh
