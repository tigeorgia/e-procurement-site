class WhiteListItem < ActiveRecord::Base
  attr_accessible :id,
    :organization_id,
    :organization_name,
    :issue_date,
    :agreement_url,
    :company_info_url
end 
