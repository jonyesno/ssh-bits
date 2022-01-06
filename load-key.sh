#!/bin/sh -e

if [ -z $1 ] ; then echo "usage: load-key keyname" ; exit 1 ; fi

# /Volumes/key is a cryptofs mount
KEYSTORE=/Volumes/key/ssh
KEYFILE=(${KEYSTORE}/id_???-$1)
echo $KEYFILE
FILE=${HOME}/.ssh/.ssh-agent-$1

if [ ! -f ${FILE} ] ; then echo "no agent environment at ${FILE}" ; exit 1 ; fi
if [ ! -f ${KEYFILE} ] ; then echo "no key at ${KEYFILE}" ; exit 1; fi

. ${FILE}

# Add the named key to the agent, with prompting turned on
if [ -z ${USE_STDIN} ] ; then
  ssh-add -c ${KEYFILE}
else
  SSH_ASKPASS=/bin/cat setsid -w ssh-add -c ${KEYFILE}
fi
