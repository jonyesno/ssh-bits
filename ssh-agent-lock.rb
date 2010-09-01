#!/usr/bin/env ruby
require 'socket'
include Socket::Constants

# This is sort-of a CLI version of http://sshkeychain.sourceforge.net's locking
# It may only work with Apple's tweaked SSH suite
#
# $ ssh-add -l
# 1024 1a:6b:2b:28:9b:fd:59:d8:61:af:9e:0e:18:db:02:2e /Volumes/key/ssh/id_dsa-732 (DSA)
#
# $ ssh-agent-lock.rb lock
# $ ssh-add -l
# The agent has no identities.
#
# $ ~/bin/ssh-agent-lock.rb unlock
# $ ssh-add -l
# 1024 1a:6b:2b:28:9b:fd:59:d8:61:af:9e:0e:18:db:02:2e /Volumes/key/ssh/id_dsa-732 (DSA)

LOCK=22
UNLOCK=23

raise RuntimeError, "No agent to lock" unless ENV.has_key?('SSH_AUTH_SOCK')

op = ARGV.shift
if op.nil? || op.match(/^lock/i)
  cmd = LOCK.chr
else
  cmd = UNLOCK.chr 
end

# XXX clarify buffer length and null
hdr = 00.chr + 00.chr + 00.chr +  5.chr
msg = 00.chr + 00.chr + 00.chr + 00.chr # null pass
                    
msg = hdr + cmd + msg

UNIXSocket.open(ENV['SSH_AUTH_SOCK']) do |s|
  sent = s.send(msg, 0)
end
