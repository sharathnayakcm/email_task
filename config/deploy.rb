require 'bundler/capistrano'

set :user, 'roruser'
set :domain, 'http://124.30.122.233:3003'
set :applicationdir, "/projects/beehive_copy"

set :scm, 'git'
set :branch, 'master'
set :repository,  "gitosis@124.30.122.233:beehive.git"
set :deploy_via, :remote_cache
set :scm_verbose, true

set :env ,"development"
set :port,3003

# roles (servers)
role :web, "domain"
role :app, "domain"
role :db,  "domain", :primary => true

# deploy config
set :deploy_to, "/projects/beehive_copy"
set :deploy_via, :export

# additional settings
default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/home/user/.ssh/id_rsa)            # If you are using ssh_keysset :chmod755, "app config db lib public vendor script script/* public/disp*"set :use_sudo, false

namespace :deploy do
  task :start, :roles => :app do
    run "cd #{deploy_to} && ruby script/rails -d #{port}"
  end

  task :stop, :roles => :app do
    run "cd #{deploy_to}"
  end

  ## After/Before rule need to specify yet
#  before 'update_code'
#  after "deploy:setup", "deploy:start"

end