#!/bin/sh

KEY=$1

[[ -n "${KEY}" ]] || exit 1

rm -v ${HOME}/tmp/ssh-askpass-defeat-id_{dsa,rsa,ed2}-${KEY}
