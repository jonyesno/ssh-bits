#!/bin/sh 

# This script is run by ssh-agent for keys marked for confirmation
# (ie: added with ssh-add -c)

STAMP_DIR=${HOME}/tmp
ME=${STAMP_DIR}/ssh-askpass-$$
IT=${STAMP_DIR}/ssh-agent-auth
WAV=${HOME}/etc/fastblip1.wav
FN=${_SSH_KEY##*/}

# mark the arrival time of the confirmation request
# we compare the mtime of this file against and adjacent
# file. this adjcacent file gets updated by a UI prompt
START=$(date +%s)
touch ${ME}

# syslog and growl the incoming request from ssh-agent
logger -t info "ssh-askpass ${FN}"
${HOME}/bin/ssh-growl.rb ${FN} &

# check to see if global or key-specific override markers exist
if [ -f ${HOME}/tmp/ssh-askpass-defeat ] || \
   [ -f ${HOME}/tmp/ssh-askpass-defeat-${FN} ] ; then
  exit 0
fi

# loop over a sleep whilst waiting to see if the 'other' file
# has been updated. nag with a beep occasionally
while [ ${ME} -nt ${IT} ] ; do 
  sleep 0.5
  NOW=$(date +%s)
  DELTA=$(( (${NOW} - ${START}) % 10 ))
  if [ ${DELTA} -eq 0 ] ; then
    ${HOME}/bin/playsound ${WAV} 
  fi

  # decline the request if told to
  if [ -f ${HOME}/tmp/ssh-askpass-decline ] ; then
    rm ${HOME}/tmp/ssh-askpass-decline 
    exit 1
  fi
done	

# growl success
${HOME}/bin/ssh-growl.rb confirmed &
rm -f ${ME}

exit 0
