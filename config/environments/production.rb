BootstrapStarter::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_mailer.raise_delivery_errors = true
  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  config.assets.compress = true
  config.assets.debug = false

	# devise requires
  config.action_mailer.delivery_method = :smtp
	config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.default_url_options = {
    :host => "tenderwatch.tigeorgia.webfactional.com",
    :locale => "en"
  }
    
end
