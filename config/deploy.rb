require "bundler/capistrano"



### Local server ###
#require "rvm/capistrano"
#set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"") # Read from local system
#set :rvm_ruby_string, "ruby-1.9.2-p290"
#set :rvm_type, :user
#before 'deploy', 'rvm:install_rvm'
#set :application, "procurement"
#server "192.168.0.241", :app, :web, :db, :primary => true
#set :user, "tigeorgia"
#set :deploy_to, "/var/data/procurement/app"
#set :scm, "git"
#set :branch, "master"
#set :repository, "git://github.com/tigeorgia/e-procurement-site.git"
#default_run_options[:pty] = true
#set :scm_username, "ChrisTIGeorgia"
#set :use_sudo, false


### Live server ###
set :application, "tenderwatch"
set :deploy_to, "/home/tigeorgia/webapps/tenderwatch"
set :scm, "git"
set :branch, "master"
set :repository, "git://github.com/tigeorgia/e-procurement-site.git"
default_run_options[:pty] = true
role :web, "web331.webfaction.com"
role :app, "web331.webfaction.com"
role :db, "web331.webfaction.com", :primary => true
set :user, "tigeorgia"
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


=begin desc "Install Passenger"
  task :install_passenger do
    install_passenger_module
    config_passenger
  end

  desc "Install Passenger Module"
  task :install_passenger_module do
    sudo "gem install passenger --no-ri --no-rdoc"
    input = ''
    run "sudo passenger-install-apache2-module" do |ch,stream,out|
      next if out.chomp == input.chomp || out.chomp == ''
      print out
      ch.send_data(input = $stdin.gets) if out =~ /(Enter|ENTER)/
    end
  end

  desc "Configure Passenger"
  task :config_passenger do
    ruby_version = "ruby-1.9.2-p290@bootstrap_starter" 
    version = 'ERROR'#default
    #passenger (2.0.3, 1.0.5)
    run("gem list | grep passenger") do |ch, stream, data|
      version = data.sub(/passenger \(([^,]+).*/,"\\1").strip
    end

    puts "passenger version #{version} configured"

    passenger_config =<<-EOF
      LoadModule passenger_module ~/.rvm/gems/#{ruby_version}/gems/passenger-#{version}/ext/apache2/mod_passenger.so
      PassengerRoot ~/.rvm/gems/#{ruby_version}/gems/passenger-#{version}
      PassengerRuby ~/.rvm/wrappers/#{ruby_version}/ruby
    EOF

    put passenger_config, "src/passenger"
    sudo "mv src/passenger /etc/apache2/conf.d/passenger"
  end
=end
