case platform
when "gentoo"
  set[:portage][:layman][:storage] = "/var/lib/layman"
else
  raise "This cookbook is Gentoo-only"
end
