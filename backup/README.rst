Description
===========

This cookbook provides a sftp-only account for client nodes that wish to store
backups on this node.


Usage
=====

You need to create a backup entry in the users databag for this recipe to work:
::

  self[:comment] = "added for backup"
  self[:shell] = "/bin/bash"
  self[:home] = "/backup"
  self[:home_mode] = "0755"
  self[:home_owner] = "root"
  self[:home_group] = "root"
  self[:gid] = "backup"
  self[:password] = "<password hash here>"

Now add role[backup] to your backup server node and converge. For client setup
read the documentation in the duply cookbook.
