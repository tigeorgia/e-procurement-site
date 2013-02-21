class AlertMailer < ActionMailer::Base
  default from: "alerts@procwatch.com"

  def search_alert(user, search)
    @search = search
    mail(:to => user.email, :subject => "New Search Updates")
  end

  def tender_alert(user, tender)
    @tender = tender
    mail(:to => user.email, :subject => "New Tender Updates")
  end
end
