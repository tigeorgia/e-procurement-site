require "bundler/capistrano"



### Local server ###
require "rvm/capistrano"
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"") # Read from local system
set :rvm_ruby_string, "ruby-1.9.2-p290"
set :rvm_type, :user
before 'deploy', 'rvm:install_rvm'
set :application, "procurement"
server "192.168.0.241", :app, :web, :db, :primary => true
set :user, "tigeorgia"
set :deploy_to, "/var/data/procurement/app"
set :scm, "git"
set :branch, "master"
set :repository, "git://github.com/tigeorgia/e-procurement-site.git"
default_run_options[:pty] = true
set :scm_username, "ChrisTIGeorgia"
set :use_sudo, false


set :default_environment, {
  'PATH' => "#{deploy_to}/bin:$PATH",
  'GEM_HOME' => "#{deploy_to}/gems" 
}

namespace :deploy do
  desc "Restart nginx"
  task :restart do
    run "#{deploy_to}/bin/restart"
  end
end


namespace :gems do
  task :bundle, :roles => :app do
    run "cd #{release_path} && bundle install  --deployment --without development test"
  end
end

after "deploy:update_code", "gems:bundle"
