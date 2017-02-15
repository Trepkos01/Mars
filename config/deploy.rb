lock '3.5.0'

set :user, "steada34"
set :domain, "mars-score.com"
set :project, "MARS"
set :application, 'mars-score.com'
set :repo_url, 'https://github.com/godfathersama/MARS.git'
set :applicationdir, "/home/#{:user}/#{:application}"

set :repository, "ssh://steada34@aberration.dreamhost.com/home/steada34/repos/MARS.git"

ssh_options = {forward_agent: true, port: 3456}
default_run_options = {pty: true}

set :scm, :git
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true

role :web, :domain                       
role :app, :domain                       
role :db,  :domain, :primary => true 

set :deploy_to, :applicationdir
set :deploy_via, :remote_cache  
set :chmod755, "app config db lib public vendor script script/* public/disp*"
 
set :normalize_asset_timestamps, false

set :stages, ["production"]
set :default_stage, "production"

SSHKit.config.command_map[:rake]  = "bundle exec rake"
SSHKit.config.command_map[:rails] = "bundle exec rails"

set :log_level, :info

set :linked_files, %w{config/database.yml config/config.yml}
set :linked_dirs, %w{bin log tmp vendor/bundle public/system}

set :keep_releases, 5

namespace :deploy do

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join("tmp/restart.txt")
    end
  end

  after :finishing, "deploy:cleanup"

end