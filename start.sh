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

# aim: idempotent, make sure All The Things are configured

[ -d .git ] || exec ./part/gitify.sh
