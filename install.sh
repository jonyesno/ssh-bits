#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

TARGETS="
	clear-agents
	create-ssh-agent-for-key
	load-key
	ssh-agent-auth
	ssh-agent-loader
	ssh-askpass-decline
	ssh-askpass
	ssh-decline
	ssh-defeat
	ssh-undefeat
	ssh-with-lookup
	ssh-yolo
"

mkdir -p ~/bin
for target in ${TARGETS} ; do
	chmod a+x "${target}"
	ln -nsf "${DIR}/${target}" "${HOME}/bin/${target}"
	ls -l "${HOME}/bin/${target}"
done

ln -nsf "${DIR}/ssh-with-lookup" "${HOME}/bin/scp-with-lookup"
ls -l "${HOME}/bin/scp-with-lookup"
