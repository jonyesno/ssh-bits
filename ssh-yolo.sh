#!/usr/bin/env bash

AGENT=$1

unyolo() {
  notify "unyolo ${AGENT}" || true
  ssh-undefeat.sh ${AGENT} || true
}
trap unyolo ERR EXIT

notify() {
  terminal-notifier -title SSH -subtitle "¯\_(ツ)_/¯" -group ssh-askpass -message "$@" -sound Tink >/dev/null 2>&1
}

if [ -z "${AGENT}" ] ; then
  notify "no agent to yolo"
  exit 1
fi

notify "yolo ${AGENT}"
ssh-defeat.sh $1
sleep 600
# ssh-undefeat via exit handler
