class TenderCpvClassifier < ActiveRecord::Base
  has_and_belongs_to_many :cpv_groups
  attr_accessible :cpv_code,
  :description,
  :description_english
  validates :cpv_code, :presence => true
end
