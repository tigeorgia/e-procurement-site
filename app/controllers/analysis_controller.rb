class AnalysisController < ApplicationController

  def index 
    tenders = Tender.where( "tender_announcement_date >= '2013-01-01' AND tender_announcement_date <= '2013-12-31'")
    total = 0
    simple_electronic = 0
    electronic = 0
    procedure = 0
    consolidated = 0
    tenders.each do |tender|
      if tender.tender_type == "ET"
        electronic += tender.estimated_value
      else if tender.tender_type == "SET"
        simple_electronic += tender.estimated_value
      else if tender.tender_type == "C"
        consolidated += tender.estimated_value
      else
        procedure += tender.estimated_value
      end
    end
  end
end
