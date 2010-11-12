default[:php][:use_flags] = []
default[:php][:default_use_flags] = %w(-* bzip2 cli crypt ctype curl exif filter ftp gd hash iconv json mysql mysqli nls pcre pdo posix reflection session simplexml sockets spl ssl tokenizer truetype unicode xml zlib)
default[:php][:sapi] = "fpm"

default[:php][:tmp_dir] = "/var/tmp/php"

if File.exists?('/usr/lib/php5/lib/php/extensions/no-debug-non-zts-20060613')
  set[:php][:extension_dir] = '/usr/lib/php5/lib/php/extensions/no-debug-non-zts-20060613'
else
  set[:php][:extension_dir] = '/usr/lib/php5/lib/extensions/no-debug-non-zts-20060613'
end

# misc php settings
default[:php][:short_open_tag] = "On"
default[:php][:allow_call_time_pass_reference] = "Off"
default[:php][:display_errors] = "Off"
default[:php][:expose_php] = "Off"
default[:php][:magic_quotes_gpc] = "Off"
default[:php][:max_execution_time] = "30"
default[:php][:max_input_nesting_level] = "64"
default[:php][:max_input_time] = "60"
default[:php][:memory_limit] = "128M"
default[:php][:post_max_size] = "8M"
default[:php][:realpath_cache_size] = "16k"
default[:php][:register_argc_argv] = "Off"
default[:php][:register_globals] = "Off"
default[:php][:register_long_arrays] = "Off"

# session settings
default[:php][:session][:auto_start] = "0"
default[:php][:session][:lifetime] = "60"
default[:php][:session][:save_path] = "#{node[:php][:tmp_dir]}/sessions"
default[:php][:session][:use_only_cookies] = "1"

# upload settings
default[:php][:upload][:max_filesize] = "2M"
default[:php][:upload][:tmp_dir] = "#{node[:php][:tmp_dir]}/uploads"

# php fpm settings
default[:php][:fpm][:socket_user] = "nobody"
default[:php][:fpm][:socket_group] = "nobody"
default[:php][:fpm][:socket_mode] = "0660"
default[:php][:fpm][:user] = "nobody"
default[:php][:fpm][:group] = "nobody"
default[:php][:fpm][:max_children] = "4"
