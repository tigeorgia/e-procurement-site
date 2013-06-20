require "bundler/capistrano"
#require 'capistrano/ext/multistage'

#set :stages, ["staging", "production"]
#set :default_stage, "staging"
set :application, "tenderstage"
set :scm, "git"
set :branch, "master"
set :repository, "git://github.com/tigeorgia/e-procurement-site.git"
default_run_options[:pty] = true
set :scm_username, "ChrisTIGeorgia"
set :user, "tigeorgia"
set :use_sudo, false

set :app_path, "/home/tigeorgia/webapps"
set :deploy_to, "#{app_path}/#{application}"
set :assets_path, "#{deploy_to}_static"
role :web, "web331.webfaction.com"
role :app, "web331.webfaction.com"
role :db, "web331.webfaction.com", :primary => true

namespace :deploy do
  desc "Restart nginx"
  task :restart do
    run "#{deploy_to}/bin/restart"
  end
end


set :default_environment, {
  'PATH' => "#{deploy_to}/bin:$PATH",
  'GEM_HOME' => "#{deploy_to}/gems" 
}

namespace :gems do
  task :bundle, :roles => :app do
    run "cd #{release_path} && bundle install  --deployment --without development test"
  end
end
after "deploy:update_code", "gems:bundle"

namespace :db do
  task :migrate, :roles => :db do
    run "cd #{release_path} && rake db:migrate"
  end
end  
after "deploy:update_code", "db:migrate"

namespace :custom do
   task :settings_config, :roles => :app do
    run "cp -f #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "cp -f #{shared_path}/config/setup_mail.rb #{release_path}/config/initializers/setup_mail.rb"
  end
end
after "deploy:update_code", "custom:settings_config"

namespace :custom do
  task :deploy_static_assets, :roles => :app do
    run "cp -r -f #{release_path}/public/assets/* #{assets_path}"
  end
end
after "deploy:update_code", "custom:deploy_static_assets"


