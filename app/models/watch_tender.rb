class WatchTender < ActiveRecord::Base
  belongs_to :user  
  attr_accessible :id,
      :tender_url,
      :user_id
end
