class BlackListItem < ActiveRecord::Base
  attr_accessible :id,
    :organization_id,
    :tender_id,
    :issueDate,
    :procurer,
    :tenderNum,
    :reason
end
