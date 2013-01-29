class CpvGroup < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :tender_cpv_classifiers

  attr_accessible :id,
      :user_id
      :name
end
