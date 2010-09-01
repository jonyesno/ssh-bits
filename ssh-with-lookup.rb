#!/usr/bin/env ruby
require 'yaml'

SERVERS = YAML::load_file(File.join(ENV['HOME'], "/etc/ssh-with-lookup.yml"))

target    = ARGV.shift
raise ArgumentError, "usage: ssh-with-lookup.rb <host>.<key> [ssh params ... ]" if target.nil?

host, key = target.split('.')
rest      = ARGV.join(' ')
raise ArgumentError, "usage: ssh-with-lookup.rb <host>.<key> [ssh params ... ]" if host.nil? || key.nil?
raise ArgumentError, "unknown key" unless SERVERS.has_key?(key)

# grab the default config for this key
conf = SERVERS[key]['default']

# if there's a specific host entry, override from tat
if SERVERS[key].has_key?(host)
  conf.merge!(SERVERS[key][host])
elsif conf.has_key?('host-suffix') # for defaulting hosts, append the key-wide host suffix if supplied
  conf['host'] = host + conf['host-suffix']
end

raise ArgumentError, "unknown host" unless conf.has_key?('host')

# discover the file containing the ssh-agent details we want
agentenv = ENV['HOME'] + "/.ssh-agent-#{conf['key']}"
raise RuntimeError, "no agent config found at #{agentenv}" unless File.exists?(agentenv)

# set this processes environment from the file's contents
File.open(agentenv, 'r') do |f|
  while line = f.gets do
    line.gsub!(/;.*/, '')
    next unless line.match(/^SSH/)
    key, value = line.chomp.split('=')
    ENV[key] = value
  end
end

# do it
cmd = "ssh #{conf['options']} #{conf['host']} #{rest}" 
puts cmd
exec cmd
