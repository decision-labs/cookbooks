maintainer       "Benedikt Böhm"
maintainer_email "bb@xnull.de"
license          "Apache 2.0"
description      "Manage random passwords"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
supports         "gentoo"
depends          "portage"

attribute "password/directory",
  :display_name => "Password directory",
  :description  => "Store locally generated passwords in this directory (passwords are not persisted if empty)",
  :type         => "string",
  :default      => ""
