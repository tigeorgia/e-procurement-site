BootstrapStarter::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_mailer.raise_delivery_errors = true
  config.assets.compress = true
  config.assets.debug = false
  config.assets.css_compressor = :yui
  config.assets.js_compressor = :uglifier

	# devise requires
  config.action_mailer.delivery_method = :smtp
	config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.default_url_options = {
    :host => "tenderwatch.tigeorgia.webfactional.com",
    :locale => "en"
  }
    
end
