#!/bin/sh

KEY=$1
AGENT=id_dsa-${KEY}

[[ -n "${KEY}" ]] || exit 1

touch ${HOME}/tmp/ssh-askpass-defeat-${AGENT}
