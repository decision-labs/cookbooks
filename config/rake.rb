# Configure the Rakefile's tasks.

# License for new Cookbooks
NEW_COOKBOOK_LICENSE = :apachev2

# The top of the repository checkout
TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), ".."))

# Directories needed by the SSL tasks
SSL_CA_DIR = File.expand_path(File.join(TOPDIR, "ca"))
SSL_CERT_DIR = File.expand_path(File.join(TOPDIR, "site-cookbooks/openssl/files/default/certificates"))

# OpenSSL config file
SSL_CONFIG_FILE = File.expand_path(File.join(TOPDIR, "config", "openssl.cnf"))

# The company name - used for SSL certificates, and in srvious other places
COMPANY_NAME = "Example Com"

# The Country Name to use for SSL Certificates
SSL_COUNTRY_NAME = "DE"

# The State Name to use for SSL Certificates
SSL_STATE_NAME = "Berlin"

# The Locality Name for SSL - typically, the city
SSL_LOCALITY_NAME = "Berlin"

# What department?
SSL_ORGANIZATIONAL_UNIT_NAME = "Operations"

# The SSL contact email address
SSL_EMAIL_ADDRESS = "hostmaster@example.com"
