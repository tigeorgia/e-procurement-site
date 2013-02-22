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

  def data_process_started()
    mail(:to => Chris@transparency.ge, :subject => "data process started")
  end
  def data_process_finished()
    mail(:to => Chris@transparency.ge, :subject => "data process finished")
  end

  def meta_started()
    mail(:to => Chris@transparency.ge, :subject => "meta started")
  end
end
