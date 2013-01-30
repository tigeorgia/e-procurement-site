class RootController < ApplicationController
  require 'scraper_file'

  def index
    gon.tender_pie_chart = Tender.tender_status_proportional
    tenders = Tender.find(:all, :select =>'distinct tender_status')
    @uniqueStatus = []
    tenders.each do |tender|
      @uniqueStatus.push(tender.tender_status)
    end
    #Get special profile account cpv groups
    profileAccount = User.where( :role => "profile" ).first
    @cpvGroups = []    
    profileAccount.cpvGroups.each do |group|
      @cpvGroups.push(group)
    end
    if user_signed_in?
      current_user.cpvGroups.each do |group|
        @cpvGroups.push(group)
      end
		end
  end

  def build_user_data
    ScraperFile.buildUserDataOnly  
  end

  def process_full_scrape
    ScraperFile.processFullScrape
  end

  def process_incremental_scrape
    ScraperFile.processIncrementalScrape
  end

  def generate_cpv_codes
    ScraperFile.createCPVCodes
  end

end 
