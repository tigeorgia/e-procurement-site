class AlertMailer < ActionMailer::Base
  default from: "alerts@procwatch.com"

  def search_alert(user)
    mail(:to => user.email, :subject => "New Search Updates")
  end
end
