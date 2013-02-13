class AlertMailer < ActionMailer::Base
  default from: "alerts@procwatch.com"

  def search_alert(user)
    mail(:to => user.email, :subject => "New Search Updates")
  end

  def tender_alert(user)
    mail(:to => user.email, :subject => "New Tender Updates")
  end
end
