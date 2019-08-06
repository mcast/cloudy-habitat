
# `cloudy-habitat`

## Problem to solve

1. I've created a new machine, usually virtual but less often on physical hardware
2. I do things in / with / to this machine environment,
  * fetch and unpack the usual tools I have in my user account
  * install system-wide packages that I'm accustomed to having available
  * make edits and leave files in this user account
  * some of these changes are committed and pushed, others are stuck in progress
3. dispose of the machine
  * anything of value needs to be migrated off
  * I need to know the evacuation is finished

## The plan - moving in

1. fetch a tarball or `git clone` or something, just get this project unpacked
2. the `sudo` version,
  1. mark the working copy as permitted to `sudo`; because in some places it is [bad to even try](https://xkcd.com/838/).
  2. check the OS type & release
  3. update package listing
  4. install some packages from file
  5. whinge if there isn't a file
  6. now there are tools, continue with the non-sudo stuff
3. if it isn't already a git clone, turn this thing into one
4. `git clone` some other things I like to have around
5. fix up some dotfiles by compare & replace

## The plan - staying up to date

## The plan - moving out
