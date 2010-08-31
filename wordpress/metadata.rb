maintainer       "Submarine Internet GmbH"
maintainer_email "hostmaster@subma.net"
license          "Apache 2.0"
description      "Installs/Configures wordpress"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
supports         "gentoo"

depends          "mysql"
depends          "nginx"
depends          "portage"
depends          "memcached"
