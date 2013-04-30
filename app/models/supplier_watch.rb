class SupplierWatch < ActiveRecord::Base
  belongs_to :user  
  attr_accessible :id,
      :supplier_id,
      :user_id,
      :email_alert,
      :has_updated
end
