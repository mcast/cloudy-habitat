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

mkdir -pv -m 0700 ~/.ssh
[ -f ~/.ssh/config ] || cp -av part/ssh.config ~/.ssh/config

mkdir -p ~/bin

GH_REPO_DIR="$( grep GH_REPO_DIR constants.txt | cut -f2 )"
mkdir -p "$HOME/$GH_REPO_DIR"

(
    cd "$HOME/$GH_REPO_DIR"
    if ! [ -d git-yacontrib ]; then
	git clone https://github.com/mcast/git-yacontrib
	git-yacontrib/install.sh -y ~/bin
	# git-yacontrib/install.sh -yS # the scary commands
    fi
)

# move this proj down to GH_REPO_DIR
new_ch_dir="$HOME/$GH_REPO_DIR/cloudy-habitat"
if [ "$( pwd )" != "$new_ch_dir" ]; then
    mv -v "$( pwd )" "$new_ch_dir"
    cd "$new_ch_dir"
fi

# TODO: ugh, this looks like a mini version control system
for f in ~/.bashrc; do
    have=$( md5sum "$f" | cut -d' ' -f1 )
    patch="patch/$have,$( basename "$f" )".diff
    echo
    if [ -s "$patch" ]; then
	patch --backup-if-mismatch --verbose "$f" "$patch"
    elif [ -f "$patch" ]; then
	echo patch for $f - looks already applied
    else
	echo no patch found for $f at $patch
    fi
done

echo $PATH | grep -q ~/bin || printf "\nPATH update needed in this shell,\n    %s\n\n" "PATH=~/bin:$PATH"

if ! [ -d "$HOME/.Private" ] && which ecryptfs-setup-private > /dev/null; then
    printf "\necryptfs-utils: activate with\n  ecryptfs-setup-private --wrapping\n\n"
fi

echo finished
