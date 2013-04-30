class ProcurerWatch < ActiveRecord::Base
  belongs_to :user  
  attr_accessible :id,
      :procurer_id,
      :user_id,
      :email_alert,
      :has_updated
end
