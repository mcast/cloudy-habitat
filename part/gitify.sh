#! /bin/sh

# Run from top project directory

fixup() {
    set -x
    rm -vf part/gitify.sh
    rm -rf tmp.checkout
    git clone https://github.com/mcast/cloudy-habitat tmp.checkout
    mv tmp.checkout/.git
    git reset --hard HEAD
    rm -rf tmp.checkout
    set +x
    sleep 3
    echo re-running ./start.sh
    exec ./start.sh
}

if [ -d .git ]; then
    echo running in a directory which already has .git - abort
    exit 1
fi

# in a function because the script is about to disappear
fixup
