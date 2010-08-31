#!/usr/bin/env ruby

# the sole reason to not use normal growl CLI is this allows
# us to configure a different growl profile for SSH prompts

require 'rubygems'
require 'ruby-growl'

growl = Growl.new "localhost", "ssh-agent", ["Agent activity"],
                  nil, 'woof'

growl.notify "Agent activity", "SSH Agent", ARGV.join(" ")
                  
