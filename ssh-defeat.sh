#!/bin/sh

KEY=$1

[[ -n "${KEY}" ]] || exit 1

touch ${HOME}/tmp/ssh-askpass-defeat-id_{dsa,rsa}-${KEY}
