#!/bin/sh -e

if [ -z $1 ] ; then echo "usage: create-ssh-agent-for-key keyname" ; exit 1 ; fi

# /Volumes/key is a cryptofs mount
KEYSTORE=/Volumes/key/ssh
KEYFILE=(${KEYSTORE}/id_???-$1)
echo $KEYFILE
FILE=${HOME}/.ssh/.ssh-agent-$1

if [ ! -f ${KEYFILE} ] ; then echo "no key at ${KEYFILE}" ; exit 1; fi

# By setting SSH_ASKPASS we provde ssh-agent with a program to run before
# it forwards a key onwards
# The ssh-askpass.sh script uses the value of ${_SSH_KEYFILE} to indicate which
# key is being requested
# ${DISPLAY} is null'd since we're expected to provide a X11 client, not a script
_SSH_KEYFILE=${KEYFILE} SSH_ASKPASS=${HOME}/bin/ssh-askpass.sh DISPLAY=dummy ssh-agent > ${FILE}
. ${FILE}
