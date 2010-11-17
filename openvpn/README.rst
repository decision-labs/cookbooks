Description
===========

OpenVPN server installation and configuration. Currently only routed/tunneled
mode is supported and only one openvpn server per node is possible.


Usage
=====

Include the openvpn::server recipe to install and configure the openvpn server.


Client Configuration
====================

You need to create an SSL certificate for each client that connects to the
OpenVPN server:
::

  rake ssl:cert[openvpn-myuser] BATCH=1

The following files need to be copied to the client node:

* site-cookbooks/openssl/files/default/certificates/ca.crt
* site-cookbooks/openssl/files/default/certificates/openvpn-myuser.key
* site-cookbooks/openssl/files/default/certificates/openvpn-myuser.crt

A simple client configuration might looks like this:
::

  tls-client
  pull

  dev tun
  remote openvpnserver.example.com
  port 1194
  proto udp

  ca ca.crt
  cert openvpn-myuser.crt
  key openvpn-myuser.key

  persist-key
  persist-tun

  comp-lzo
  verb 3


Client GUIs
===========

* Linux
  * `NetworkManager <http://www.gnome.org/projects/NetworkManager/>`_
  * `KVpnc <http://home.gna.org/kvpnc/en/index.html>`_
* MacOS X
  * `Tunnelblick <http://code.google.com/p/tunnelblick/>`_
  * `Viscosity <http://www.thesparklabs.com/viscosity/>`_
* Windows
