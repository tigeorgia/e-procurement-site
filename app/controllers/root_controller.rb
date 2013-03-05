class RootController < ApplicationController
  require 'scraper_file'

  def index
    tenders = Tender.find(:all, :select =>'distinct tender_status')
    @uniqueStatus = []
    tenders.each do |tender|
      @uniqueStatus.push(tender.tender_status)
    end
    #Get special profile account cpv groups
    profileAccount = User.where( :role => "profile" ).first
    @cpvGroups = []
    if profileAccount 
      profileAccount.cpvGroups.each do |group|
        @cpvGroups.push(group)
      end
      if user_signed_in?
        current_user.cpvGroups.each do |group|
          @cpvGroups.push(group)
        end
		  end
    end
    
    @orgTypes = []
    orgs =  Organization.where(:is_bidder => 1).select("DISTINCT(ORG_TYPE)")
    orgs.each do |org|
      @orgTypes.push(org["ORG_TYPE"])
    end

    @procTypes = []  
    procs = Organization.where(:is_procurer => 1).select("DISTINCT(ORG_TYPE)")
    procs.each do |proc|
      @procTypes.push(proc["ORG_TYPE"])
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
