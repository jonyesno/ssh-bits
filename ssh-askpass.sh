#!/bin/sh

# This script is run by ssh-agent for keys marked for confirmation
# (ie: added with ssh-add -c)

STAMP_DIR=${HOME}/tmp
ME=${STAMP_DIR}/ssh-askpass-$$
IT=${STAMP_DIR}/ssh-agent-auth
if [ -z "${_SSH_KEYFILE}" ] ; then
  FN=$( echo $* | awk '{print $NF;}' )
else
  FN=${_SSH_KEYFILE##*/}
fi
LOG=${HOME}/tmp/ssh-askpass.log

trace() {
  NOW=$( date )
  echo "[ssh-askpass-$$] ${NOW} $*" >> ${LOG}
}

trace "called: $0 $*"

# mark the arrival time of the confirmation request
# we compare the mtime of this file against and adjacent
# file. this adjcacent file gets updated by a UI prompt
mkdir -p ${STAMP_DIR}
START=$(date +%s)
touch ${ME}

# syslog and growl the incoming request from ssh-agent
trace $FN

# check to see if global or key-specific override markers exist
if [ -f ${HOME}/tmp/ssh-askpass-defeat ] || \
   [ -f ${HOME}/tmp/ssh-askpass-defeat-${FN} ] ; then
# terminal-notifier -title SSH -subtitle "Automatic use of ssh-agent" -group ssh-askpass -message ${FN} -sound Tink
  rm -f ${ME}
  exit 0
fi

# loop over a sleep whilst waiting to see if the 'other' file
# has been updated
reattach-to-user-namespace terminal-notifier -title SSH -subtitle "Allow use of ssh-agent?" -group ssh-askpass -message ${FN} -sound Tink -execute ${HOME}/bin/ssh-agent-auth.sh
while [ ${ME} -nt ${IT} ] ; do
  sleep 0.5
  NOW=$(date +%s)
  DELTA=$(( (${NOW} - ${START}) % 10 ))
  if [ ${DELTA} -eq 0 ] ; then
    trace "nudge"
  fi

  # decline the request if told to
  if [ -f ${HOME}/tmp/ssh-askpass-decline ] ; then
    rm ${HOME}/tmp/ssh-askpass-decline
    trace "decline"
    exit 1
  fi
done

# growl success
# ${HOME}/bin/ssh-growl.rb confirmed &
rm -f ${ME}

reattach-to-user-namespace terminal-notifier -remove ALL >> ${LOG} 2>&1
trace "accept"

exit 0
