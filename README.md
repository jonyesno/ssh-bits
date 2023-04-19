# Overview

This collection of shamefully scrappy scripts do two main things:

1. Run different SSH agents for different keys, so that a compromised agent
   has only limited use (eg: root on client A's hosts can't use it access
   client B's hosts).

2. Require `ssh-agent` to prompt for confirmation before it uses a key, so that
   a compromised agent stands less chance of being exploited (if the user
   is away or declines the request then nothing happens).

The scripts are mostly Bourne-shell pure, although it's possible some
BASH-isms might've crept in.

`terminal-notifier` create macOS notifications. `reattach-to-user-namespace`
and `setsid` are macOS session process tools. They are available through
[Homebrew](https://brew.sh/)

There's doubtless room for improvement here. This grew over time to scratch
successive itches, and trades grace and style for getting stuff done!

# Operation

Shells source `ssh-agent-env.rc` in their profile. This defines two functions:

1. `load_agent_env`

  For a named key, this will either create a new agent for it, loading the
  key as it goes, or merely recover the environment of an existing agent.

  The create/load work is pushed to a script, `create-ssh-agent-for-key`

2. `kill_agent`

  Kills the agent of a named key

  It also defines two shell aliases, `la` for `load_agent_env,` and `xsh` for
  `ssh-with-lookup.` More on that later.

The main scripts are:

1. `create-ssh-agent-for-key`

  This script goes off to look for a SSH key whose path is derived from its
  name.  For me, this is `/Volumes/key/ssh/id_ed2-${KEYNAME}`.

  It then creates a new SSH agent and stores its environment details in a
  dotfile specific to this key, `~/.ssh/.ssh-agent-${KEYNAME}`.

  Whilst doing so it uses the `${SSH_ASKPASS}` variable to indicate to ssh-agent
  that it should run this variable's command before passing a key's deatils
  along. Keys that want such behaviour are then loaded into the agent with
  `ssh-add -c`.

2. `ssh-askpass`

  This is the program run by ssh-agent when it's asked to provide a key. It
  alerts the user to an incoming agent request and waits for confirmation.

  To decouple the user interaction from the SSH process it compares two files'
  timestamps: one from when the request came in, and one updated by the
  out-of-band confirmation process.

  The script exits zero to indicate confirmation, or non-zero to decline the
  request.

3. `ssh-agent-auth`

  This is other side of the confirmation process. The script merely update the
  timestamp of one of the files ssh-askpass is looking at. Typically it's run
  by a keyboard shortcut.

4. `ssh-decline`

  This script drops a file marker to indicate to ssh-askpass that its should
  not agree to the agent request. Again, can be run from a keyboard shortcut.

5. `ssh-with-lookup`

  This script wrappers a SSH invocation, setting up the necessary environment
  for the key's agent and providing a mechanism to fully qualify a hostname
  based on defaults and overrides.

6. `clear-agent`

  Removes the dotfiles relating to managed agents and any timestamp files. It
  doesn't actually kill the agents. It probably should.

7. `ssh-defeat`

  Drop off a marker file that disables confirmation prompting for a given key.

8. `ssh-agent-lock`

  Not part of this stuff, but a proof-of-concept agent lock/unlock script.
  See inside for more details.

# Example

Quick demo to unabstractificate this stuff:

1. Create a new agent for the jon-zikomo key:

  ```
  $ load_agent_env jon-zikomo
  No agent loaded for jon-zikomo
  Agent pid 23919
  Enter passphrase for /Volumes/key/ssh/id_ed2-jon-zikomo:
  Identity added: /Volumes/key/ssh/id_ed2-jon-zikomo (/Volumes/key/ssh/id_ed2-jon-zikomo)
  The user has to confirm each use of the key
  Agent pid 23919

  $ ssh-add -l
  256 SHA256:ueHHHX877aWrcnO19bh/Qg1A1hX6GoxdJxQ38HHHykg jon-zikomo (ED25519)
  ```

2. Create another agent for another key, using the shell alias `la`:

  ```
  $ la 732
  No agent loaded for 732
  Agent pid 25129
  Enter passphrase for /Volumes/key/ssh/id_ed2-732:
  Identity added: /Volumes/key/ssh/id_ed2-732 (/Volumes/key/ssh/id_ed2-732)
  The user has to confirm each use of the key
  Agent pid 25129

  $ ssh-add -l
  256 SHA256:udfgo973l4t00sflfkh/Qg1A1hX6GoxdJxQ94LLCVmn 732 (ED25519)
  ```

3. In a new shell, use `ssh-with-lookup`, via `xsh` shell alias, to SSH somewhere:

  ```
  $ ssh-add -l
  The agent has no identities. # This is OS X's default agent

  $ xsh hq.zikomo
  ssh -l jon hq.zikomo.xyz
  Last login: Wed Aug 11 13:12:33 2010 from somewhere.example.com
  ```

Various things now happen:

  * `ssh-with-lookup` recovered the agent details
  * it appended the `zikomo.xyz` domain and user account switch and invoked `ssh`
  * the agent was asked to key the connection
  * the agent ran `ssh-askpass`
  * `ssh-askpass` didn't exit until I confirmed it
  * which I did by pressing a keyboard shortcut that ran `ssh-agent-auth`

# Disclaimer and warranty

As suggested this is all quick and dirty hacks. No claims made about its
fitness for use, no warranty or anything like that. It may indeed eat children
and melt ice caps. Good luck.
