require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :stages, ["staging", "production"]
set :default_stage, "staging"
set :application, "tenderwatch"

set :scm, "git"
set :branch, "master"
set :repository, "git://github.com/tigeorgia/e-procurement-site.git"
default_run_options[:pty] = true
set :scm_username, "ChrisTIGeorgia"
set :user, "tigeorgia"

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

namespace(:customs) do
   task :symlink_db, :roles => :app do
    run <<-CMD
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml
      ln -nfs #{shared_path}/config/setup_mail.rb #{release_path}/config/initializers/setup_mail.rb
    CMD
  end
end
