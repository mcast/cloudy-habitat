#! /bin/sh

echo this is not a test suite, just some fragments
projdir=$( dirname "$0" )/..
cd -P "$projdir"

git grep constants.txt
# each of those needs to not overlap the others, and have a cut -f2
