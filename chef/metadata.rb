maintainer       "Benedikt Böhm"
maintainer_email "bb@xnull.de"
license          "Apache 2.0"
description      "Installs and configures Chef Client and Server"
version          "0.1"
supports         "gentoo"

%w(couchdb git portage rabbitmq).each { |cb|
  depends cb
}
