ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "procwatch",
  :password             => "lemontree40",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options = {
  :host => "0.0.0.0",
  :port => 3000,
  :locale => "en"
}
