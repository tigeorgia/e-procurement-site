class AlertMailer < ActionMailer::Base
  default from: "alerts@procwatch.com"

  def search_alert(user, search, tenders)
    @search = search
    @tenders = tenders
    mail(:to => user.email, :subject => "New Search Updates")
  end

  def tender_alert(user, tender, attributes)
    @tender = tender
    @attributes = attributes
    mail(:to => user.email, :subject => "New Tender Updates")
  end

  def data_process_started()
    mail(:to => "Chris@transparency.ge", :subject => "data process started")
  end
  def data_process_finished()
    mail(:to => "Chris@transparency.ge", :subject => "data process finished")
  end

  def meta_started()
    mail(:to => "Chris@transparency.ge", :subject => "meta started")
  end
end
