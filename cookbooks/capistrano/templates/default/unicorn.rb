worker_processes <%= @params[:worker_processes] %>
timeout <%= @params[:timeout] %>
listen <%= @params[:port] %>, :backlog => <%= @params[:backlog] %>

working_directory '<%= @params[:homedir] %>/current'
pid '<%= @params[:homedir] %>/shared/pids/unicorn.pid'

before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
