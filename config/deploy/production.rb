set :deploy_to, "/home/tigeorgia/webapps/tenderwatch"
role :web, "web331.webfaction.com"
role :app, "web331.webfaction.com"
role :db, "web331.webfaction.com", :primary => true

namespace :deploy do
  desc "Restart nginx"
  task :restart do
    run "#{deploy_to}/bin/restart"
  end
end
