# Based on chef and puppet's portage package provider.

module Gentoo
  module Portage
    module PackageConf

      # Creates or deletes per package portage attributes. Returns true if it
      # changes (sets or deletes) something.
      # * action == :create || action == :delete
      # * foo_category =~ /\A(use|keywords|mask|unmask)\Z/
      def manage_package_conf(action, conf_type, name, package = nil, flags = nil)
        conf_file = package_conf_file(conf_type, name)
        case action
        when :create
          create_package_conf_file(conf_file, normalize_package_conf_content(package, flags))
        when :delete
          delete_package_conf_file(conf_file)
        else
          raise Chef::Exceptions::Package, "Unknown action :#{action}."
        end
      end

      # Returns the portage package control file name:
      # =net-analyzer/nagios-core-3.1.2 => chef.net-analyzer-nagios-core-3-1-2
      # =net-analyzer/netdiscover => chef.net-analyzer-netdiscover
      def package_conf_file(conf_type, name)
        conf_dir = "/etc/portage/package.#{conf_type}"
        raise Chef::Exceptions::Package, "#{conf_type} should be a directory." unless ::File.directory?(conf_dir)

        package_atom = name.strip.split(/\s+/).first
        package_file = package_atom.gsub(/[\/\.|]/, "-").gsub(/[^a-z0-9_\-]/i, "")
        return "#{conf_dir}/chef-#{package_file}"
      end

      def same_content?(filepath, content)
        content.strip == ::File.read(filepath).strip
      end

      def create_package_conf_file(conf_file, content)
        return nil if ::File.exists?(conf_file) && same_content?(conf_file, content)

        ::File.open("#{conf_file}", "w") { |f| f << content + "\n" }
        Chef::Log.info("Created #{conf_file} \"#{content}\".")
        true
      end

      def delete_package_conf_file(conf_file)
        return nil unless ::File.exists?(conf_file)

        ::File.delete(conf_file)
        Chef::Log.info("Deleted #{conf_file}")
        true
      end


      # Normalizes package conf content
      def normalize_package_conf_content(name, flags = nil)
        [ name, normalize_flags(flags) ].join(' ')
      end

      # Normalizes String / Arrays
      def normalize_flags(flags)
        if flags.is_a?(Array)
          flags.sort.uniq.join(' ')
        else
          flags
        end
      end
    end

  end
end
