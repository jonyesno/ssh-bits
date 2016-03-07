#!/bin/sh

AGENT=$1

notify() {
  terminal-notifier -title SSH -subtitle "¯\_(ツ)_/¯" -group ssh-askpass -message "$@" -sound Tink
}


if [ -z "${AGENT}" ] ; then
  notify "no agent to yolo"
  exit 1
fi

notify "yolo ${AGENT}"
ssh-defeat.sh $1
sleep 600
notify "unyolo ${AGENT}"
ssh-undefeat.sh $1
