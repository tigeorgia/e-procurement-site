class SimplifiedCpv < ActiveRecord::Base
  has_and_belongs_to_many :simplified_tenders, join_table: 'simplified_tenders_cpvs'
end
