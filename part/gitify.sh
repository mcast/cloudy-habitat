#! /bin/sh

# Run from top project directory

fixup() {
    set -x
    rm -vf part/gitify.sh
    rm -rf tmp.checkout
    git clone $( grep REPO_URL constants.txt | cut -f2 ) tmp.checkout
    mv tmp.checkout/.git .
    git reset --hard HEAD
    rm -rf tmp.checkout
    set +x
    echo re-running ./start.sh soon...
    sleep 3
    exec ./start.sh
}

if [ -d .git ]; then
    echo running in a directory which already has .git - abort
    exit 1
fi

# in a function because the script is about to disappear
fixup
