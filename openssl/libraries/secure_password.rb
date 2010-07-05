require 'openssl'

module ChefUtils
  module OpenSSL
    module Password
      def secure_password(length=20)
        pw = String.new

        while pw.length < length
          pw << ::OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
        end

        pw
      end
    end
  end
end
