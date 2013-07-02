ActionMailer::Base.smtp_settings = {
  :address              => "smtp.webfaction.com",
  :port                 => 587,
  :domain               => "tendermonitor.ge",
  :user_name            => "tendermonitor",
  :password             => "k~C4S]F!R>onc>g",
  :authentication	=> "plain",
  :enable_starttls_auto => true
}
