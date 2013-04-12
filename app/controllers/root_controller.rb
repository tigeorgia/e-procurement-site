class RootController < ApplicationController
  require 'scraper_file'
  include ApplicationHelper

  def cpvVsCompany
    companies = {}
    cpvGroup = CpvGroup.find(params[:cpvGroup])
    classifiers = cpvGroup.tender_cpv_classifiers
    cpvAggregates = nil
    sqlString = ''
    #cpv group 1 is a special 'all' category since this is a huge calculation we cheat and just look at total revenue
    if cpvGroup.id == 1
      top10 = Organization.order("total_won_contract_value DESC").limit(10)
      @TopTen = []
      top10.each do |company|
        @TopTen.push( {:company => company, :total => company.total_won_contract_value} )
      end
    else
      classifiers.each do |classifier|
        cvpDropped = dropZeros(classifier.cpv_code.to_s)
        sqlString += "cpv_code LIKE '"+cvpDropped+ "%' OR "
      end
      puts sqlString
      sqlString = sqlString[0..-4]
      cpvAggregates = AggregateCpvRevenue.where(sqlString)
   
      cpvAggregates.each do |companyAggregate|
        companyData = companies[companyAggregate.organization_id]
        company = Organization.find(companyAggregate.organization_id)
        if not companyData
          companies[companyAggregate.organization_id] = { :total => companyAggregate.total_value, :company => company }
        else
          companyData[:total] = companyData[:total] + companyAggregate.total_value  
          companies[companyAggregate.organization_id] = companyData
        end
      end

      totalContractValues = []   
      companyArray = []
      companies.each do |index,hash|
        companyArray.push(hash)
      end
      companyArray.sort! { |a,b| (a[:total] > b[:total] ? -1 : 1) }
      @TopTen = []
      count = 1
      companyArray.each do |company|
        @TopTen.push(company)
        count = count + 1
        if count > 10
          break
        end
      end
    end
  end


  def index
    tenders = Tender.find(:all, :select =>'distinct tender_status')
    @uniqueStatus = []
    tenders.each do |tender|
      @uniqueStatus.push(tender.tender_status)
    end
    @indicators = []
    CorruptionIndicator.all.each do |indicator|
      if not indicator.id == 100
        @indicators.push(indicator)
      end
    end

    top10 = Organization.order("total_won_contract_value DESC").limit(10)
    @TopTen = []
    top10.each do |company|
      @TopTen.push( {:company => company, :total => company.total_won_contract_value} )
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
