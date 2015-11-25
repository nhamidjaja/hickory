# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'hickory'
set :repo_url, 'git@gitlab.com:nhamidjaja/hickory.git'

# whenever crontab
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

# https://github.com/seuros/capistrano-sidekiq/issues/49
# ERROR: no tty present and no askpass program specified
set :sidekiq_monit_default_hooks, false

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/ubuntu/hickory'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, fetch(:linked_files, []).push(
  'config/application.yml',
  'config/database.yml',
  'config/shards.yml',
  'config/cequel.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log', 
  'tmp/pids', 
  'tmp/cache', 
  'tmp/sockets', 
  'vendor/bundle', 
  'public/system', 
  'public/uploads')

# http://stackoverflow.com/questions/26151443/capistrano-3-deployment-for-rails-4-binstubs-conflict
set :bundle_binstubs, nil

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        print "WARNING: HEAD is not the same as origin/master\n"
        print "Run `git push` to sync changes.\n"
        print "Enter y if you wish to continue: "
        proceed = STDIN.gets[0..0] rescue nil
        exit unless proceed == 'y'
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    before 'deploy:finishing', 'deploy:cequel:setup'

    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Cassandra migrations'
  namespace :cequel do
    task :setup do
      on primary(:web) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, 'cequel:keyspace:create'
          end
        end 
      end
    end

    task :migrations do
      on primary(:web) do
        # run "cd #{current_path}; RAILS_ENV=#{ENV["RAILS_ENV"]} bundle exec rake cequel:migrate"
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, 'cequel:migrate'
          end
        end 
      end
    end
  end

  # before :starting,     :check_revision
  after  :migrate,      'deploy:cequel:migrations'
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
