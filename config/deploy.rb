set :application, "unfollow.paperplanes.de"
set :domain,      "unfollow.paperplanes.de"
set :repository,  "git://github.com/mattmatt/unfollow-me.git"
set :use_sudo,    false
set :deploy_to,   "/var/www/#{application}"
set :scm,         "git"
set :git_shallow_clone, 1

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Setup symlink for local twitter configuration"
  task :symlink_config, :roles => :app do
    run "ln -nfs #{shared_path}/config/twitter_local.rb #{release_path}/config/initializers/twitter_local.rb"
    run "ln -nfs #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
  end
end

after "deploy:update_code", "deploy:symlink_config"
