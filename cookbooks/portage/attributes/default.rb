case platform
when "gentoo"
  # paths & directories
  set[:portage][:make_conf] = "/etc/make.conf"
  set[:portage][:confdir] = "/etc/portage"
  set[:portage][:portdir] = "/usr/portage"
  set[:portage][:distdir] = "#{set[:portage][:portdir]}/distfiles"
  set[:portage][:pkgdir] = "#{set[:portage][:portdir]}/packages/${ARCH}"
  default[:portage][:profile] = "#{set[:portage][:portdir]}/profiles/default/linux/amd64/10.0"

  # compiler settings
  default[:portage][:CFLAGS] = "-march=athlon64 -O2 -pipe"
  default[:portage][:CXXFLAGS] = "${CFLAGS}"

  # build-time flags
  default[:portage][:USE] = []

  # advanced masking
  default[:portage][:ACCEPT_KEYWORDS] = nil

  # mirror settings
  default[:portage][:SYNC] = 'rsync://rsync.spline.de/gentoo-portage'
  default[:portage][:MIRRORS] = %w(
    ftp://ftp.spline.de/pub/gentoo
  )

  # advanced features
  default[:portage][:OPTS] = %w(--usepkg)
  default[:portage][:MAKEOPTS] = "-j1"
  default[:portage][:FEATURES] = %w(buildpkg)

  # language support
  default[:portage][:LINGUAS] = []

  # configuration file protection
  default[:portage][:CONFIG_PROTECT] = []
  default[:portage][:CONFIG_PROTECT_MASK] = []
else
  raise "This cookbook is Gentoo-only"
end
