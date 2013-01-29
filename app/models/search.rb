class Search < ActiveRecord::Base
  belongs_to :user  
  attr_accessible :id,
      :search_string,
      :user_id
end
