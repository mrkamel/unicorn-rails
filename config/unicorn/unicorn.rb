
rails_root = "/var/www/project"
worker_processes 3

working_directory rails_root
stderr_path File.join(rails_root, "log/unicorn.stderr.log")
pid File.join(rails_root, "tmp/pids/unicorn.pid")
listen "127.0.0.1:3000"
timeout 40
preload_app true

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  # Send QUIT signal to old master, if the old master
  # is still alive.

  old_pid = File.join(Rails.root, "tmp/pids/unicorn.pid.oldbin")

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill "QUIT", File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
      # Someone else already did the job for us.
    end
  end

  sleep 0.2 # Throttle forks.
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end

