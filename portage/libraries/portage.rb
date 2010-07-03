# Heavily refactored from veszig-portage library, which in turn is based on Chef's and Puppet's portage package provider

module Gentoo
  module Portage
    module Emerge
      include Gentoo::Portage::PackageConf

      def emerge_cmd(pkg, emerge_options = nil)
        "/usr/bin/emerge --color=n --nospinner --quiet #{emerge_options} #{pkg}"
      end

      def unmerge(new_resource)
        package_data = package_info_for(new_resource.name) || {}
        return nil unless package_data[:current_version].any?

        Chef::Log.info("Unmerging #{package_data[:package_atom]}.")
        Chef::Mixin::Command.run_command_with_systems_locale(
          :command => emerge_cmd(package_data[:package_atom], '--unmerge')
        )
      end

      # Memoize package info
      attr_accessor :package_info
      def package_info
        @package_info ||= package_info_for(@new_resource.name)
      end

      # Sets portage attributes and then emerges the package only if necessary.
      def conditional_emerge(new_resource, action)

        # Set package metadata that may influence our candidate search.
        %w(keywords mask unmask).each { |conf_type|
          if atoms = new_resource.send(conf_type)
            atoms = [atoms] if atoms.is_a?(String)
            atoms.each do |atom|
              manage_package_conf(:create, conf_type, atom)
            end
          end
        }

        package_data = package_info
        if package_data[:candidate_version].to_s == ""
          raise Chef::Exceptions::Package, "No candidate version available for #{new_resource.name}"
        end

        package_atom = "#{package_data[:category]}/#{package_data[:package_name]}"
        package_atom = "=#{package_atom}-#{new_resource.version}" if new_resource.version

        if new_resource.respond_to?(:use) && new_resource.use
          manage_package_conf(:create, "use", package_atom, new_resource.use)
        end

        emerge(package_data[:package_atom], new_resource.options) if emerge?(action, package_data, new_resource.version)
      end


      def package_info_for(package_name)
        info = begin
          package_info_from_eix(package_name)
        rescue Chef::Exceptions::Package => err
          Chef::Log.error("Error attempting to use EIX: #{err.inspect}")
          Chef::Log.info("Falling back to portage.")
          package_info_from_portage(package_name)
        end
        info[:package_atom] = full_package_atom(info[:category], info[:package_name], new_resource.version)
        info
      end

      private

      def emerge?(action, package_data, requested_version)
        version = requested_version.to_s

        # If we find no version, regardless of action emerge this package
        if package_data[:current_version] == ""
          Chef::Log.info("No version found. Installing package[#{package_data[:package_atom]}].")
          return true
        end

        case action
        when :install
          # If we requested any version, then do nothing
          return false if version == ""
          # If we have the same version, then do nothing
          return false if package_data[:current_version] == version

          Chef::Log.info("Installing package[#{package_data[:package_atom]}] (version requirements unmet).")
          true
        when :reinstall
          Chef::Log.info("Reinstalling package[#{package_data[:package_atom]}].")
          true
        when :upgrade
          # Do not upgrade if the version is the same.
          return false if package_data[:current_version] == package_data[:candidate_version]

          Chef::Log.info("Upgrading package[#{package_data[:package_atom]}] from version #{package_data[:current_version]}.")
          true
        else
          raise Chef::Exceptions::Package, "Unknown action :#{action}"
        end
      end

      # Emerges "package_atom" with additional "options".
      def emerge(package_atom, options)
        Chef::Mixin::Command.run_command_with_systems_locale(
          :command => emerge_cmd(package_atom, options)
        )
      end

      def full_package_atom(category, name, version = nil)
        package_atom = "#{category}/#{name}"
        return package_atom unless version

        if(version =~ /^\~(.+)/)
          # If we start with a tilde
          "~#{package_name}-#{$1}"
        else
          "=#{package_name}-#{version}"
        end
      end

      def package_info_from_portage(package_atom)
        portage_data = {}
        package_name = package_atom.split('/').last

        # When emerge is set to --quiet, it will not emit version information
        status = popen4("/usr/bin/emerge --verbose --search #{package_name}") do |pid, stdin, stdout, stderr|
          portage_data = parse_emerge_data(package_name, stdout.read)
        end

        unless status.exitstatus == 0
          raise Chef::Exceptions::Package, "emerge --search failed - #{status.inspect}!"
        end

        Chef::Log.info "Found candidate package: #{portage_data.inspect}"

        return portage_data
      end

      def parse_emerge_data(package, txt)
        available, installed, category, name, pkg = nil
        Chef::Log.info "Output from emerge --search: #{txt}"
        txt.each do |line|
          if line =~ /\*(.*)/
            pkg = $1.strip
          end
          if (pkg == package) || (pkg.split('/').last == package rescue false)
            category, name = pkg.split('/')
            if line =~ /Latest version available: (.*)/
              available = $1
            elsif line =~ /Latest version installed: (.*)/
              installed = $1
            end
          end
        end

        available = installed unless available

        return {
          :category => category,
          :package_name => name,
          :current_version => installed,
          :candidate_version => available
        }
      end


      # Searches for "package_name" and returns a hash with parsed information
      # returned by eix.
      #
      #   # git is installed on the system
      #   package_info_from_eix("git")
      #   => {
      #        :category => "dev-vcs",
      #        :package_name => "git",
      #        :current_version => "1.6.3.3",
      #        :candidate_version => "1.6.4.4"
      #      }
      #   # git isn't installed
      #   package_info_from_eix("git")
      #   => {
      #        :category => "dev-vcs",
      #        :package_name => "git",
      #        :current_version => "",
      #        :candidate_version => "1.6.4.4"
      #      }
      #   package_info_from_eix("dev-vcs/git") == package_info_from_eix("git")
      #   => true
      #   package_info_from_eix("package/doesnotexist")
      #   => nil
      def package_info_from_eix(package_name)
        eix = "/usr/bin/eix"
        eix_update = "/usr/bin/eix-update"

        unless ::File.executable?(eix)
          raise Chef::Exceptions::Package, "You need app-portage/eix installed to use gentoo_package."
        end

        # We need to update the eix database if it's older than the current portage
        # tree or the eix binary.
        unless ::FileUtils.uptodate?("/var/cache/eix", [eix, "/usr/portage/metadata/timestamp"])
          Chef::Log.debug("Eix database outdated, calling `#{eix_update}`.")
          Chef::Mixin::Command.run_command_with_systems_locale(:command => eix_update)
        end

        query_command = [eix, "--nocolor", "--pure-packages", "--stable", "--exact",
          '--format "<category>\t<name>\t<installedversions:VERSION>\t<bestversion:VERSION>\n"',
          package_name.count("/") > 0 ? "--category-name" : "--name", package_name].join(" ")

        eix_out = eix_stderr = nil

        Chef::Log.debug("Calling `#{query_command}`.")
        status = Chef::Mixin::Command.popen4(query_command) { |pid,stdin,stdout,stderr|
          eix_out = if stdout.read.split("\n").first =~ /\A(\S+)\t(\S+)\t(\S*)\t(\S+)\Z/
                      {
            :category => $1,
            :package_name => $2,
            :current_version => $3,
            :candidate_version => $4
          }
                    end
          eix_stderr = stderr.read
        }

        eix_out ||= {}
        raise Chef::Exceptions::Package, "Eix search failed: `#{query_command}`\n#{eix_stderr}\n#{status.inspect}!" unless status.exitstatus == 0
        Chef::Log.debug("Eix search for #{package_name} returned: category: \"#{eix_out[:category]}\", package_name: \"#{eix_out[:package_name]}\", current_version: \"#{eix_out[:current_version]}\", candidate_version: \"#{eix_out[:candidate_version]}\".")

        eix_out
      end
    end
  end
end

# Reopens and overrides Chef::Provider::Package::Portage
# Works with Chef 0.8.10
class Chef
  class Provider
    class Package
      class Portage < Chef::Provider::Package
        include ::Gentoo::Portage::Emerge

        def install_package(name, version)
          conditional_emerge(new_resource, :install)
        end

        def upgrade_package(name, version)
          conditional_emerge(new_resource, :upgrade)
        end

        def candidate_version
          @candidate_verison ||= self.package_info[:candidate_version]
        end

      end
    end
  end
end
