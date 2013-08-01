#!/bin/env ruby
# encoding: utf-8

class RootController < ApplicationController
  require 'scraper_file'
  include ApplicationHelper


  def generateOrganizationAggregates( dbObject, limit )
    organizations = {}
    cpvGroup = CpvGroup.find(params[:cpvGroup])
    classifiers = cpvGroup.tender_cpv_classifiers
    cpvAggregates = nil
    sqlString = ''
    hasItem = false
    classifiers.each do |classifier|
      hasItem = true
      cvpDropped = dropZeros(classifier.cpv_code.to_s)
      sqlString += "cpv_code LIKE '"+cvpDropped+ "%' OR "
    end
    sqlString = sqlString[0..-4]
    results = []
    if hasItem
      cpvAggregates = dbObject.where(sqlString)
      cpvAggregates.each do |aggregateItem|
        aggregateData = organizations[aggregateItem.organization_id]
        organization = Organization.find(aggregateItem.organization_id)
        if not aggregateData
          organizations[aggregateItem.organization_id] = { :total => aggregateItem.total_value, :company => organization }
        else
          aggregateData[:total] = aggregateData[:total] + aggregateItem.total_value  
          organizations[aggregateItem.organization_id] = aggregateData
        end
      end

      totalContractValues = []   
      orgArray = []
      organizations.each do |index,hash|
        orgArray.push(hash)
      end
      orgArray.sort! { |a,b| (a[:total] > b[:total] ? -1 : 1) }
      
      count = 1
      orgArray.each do |org|
        results.push(org)
        count = count + 1
        if count > limit
          break
        end
      end
    end
    return results
  end

  def majorGroups
    groupAggregates = []
    cpvGroups = []
    profileAccount = User.where( :role => "profile" ).first
    if profileAccount 
      profileAccount.cpvGroups.each do |group|
        cpvGroups.push(group)
      end
      if user_signed_in?
        current_user.cpvGroups.each do |group|
          cpvGroups.push(group)
        end
		  end
    end

    cpvGroups.each do |cpvGroup|
      if cpvGroup.id == 1
        next
      end
      classifiers = cpvGroup.tender_cpv_classifiers
      sqlString = ''
      hasItem = false
      classifiers.each do |classifier|
        cpvDropped = dropZeros(classifier.cpv_code.to_s)
        wildCards = ""
        for i in 1..8-cpvDropped.length
          wildCards += "_"
        end
        sqlString += "cpv_code LIKE '"+cpvDropped+wildCards+"%' OR "
        hasItem = true
      end
      if hasItem
        sqlString = sqlString[0..-4]
        cpvAggregates = AggregateCpvRevenue.where(sqlString)
        total = 0
        cpvAggregates.each do |aggregate|
          total += aggregate.total_value
        end
        if I18n.locale == :ka and cpvGroup.translation != nil
          item = {:name => cpvGroup.translation, :total => total}
        else
          item = {:name => cpvGroup.name, :total => total}
        end
        groupAggregates.push(item)
      end
    end
    
    groupAggregates.sort! { |a,b| (b[:total] <=> a[:total]) }
    @majorGroups = []
    count = 1
    groupAggregates.each do |group|
      @majorGroups.push(group)
      count = count + 1
      if count > 10
        break
      end
    end
  end

  def cpvVsProcurer
    cpvGroup = params[:cpvGroup]
    if cpvGroup == "-1"
      render nothing: true
    else
      @topTenProcurers = generateOrganizationAggregates( ProcurerCpvRevenue, 10 )    
    end  
  end

  def cpvVsCompany
    cpvGroup = params[:cpvGroup]
    sqlString = ''
    #cpv group 1 is a special 'all' category since this is a huge calculation we cheat and just look at total revenue
    if cpvGroup == "1"
      top10 = Organization.order("total_won_contract_value DESC").limit(10)
      @TopTen = []
      top10.each do |company|
        @TopTen.push( {:company => company, :total => company.total_won_contract_value} )
      end
    elsif cpvGroup == "-1"
      render nothing: true
    else
      @TopTen = generateOrganizationAggregates( AggregateCpvRevenue, 10 )   
    end
  end

  def about
  end

	def about_ka
	end

  def index
    dataset = Dataset.find(1)
    @updateTime = dataset.data_valid_from
    @nextUpdate = dataset.next_update
    #buildOrganizationXmlStrings
    tenders = Tender.find(:all, :select =>'distinct tender_status')
    @uniqueStatus = []
    tenders.each do |tender|
      @uniqueStatus.push(tender.tender_status)
    end

    tenders = Tender.find(:all, :select =>'distinct tender_type')
    @uniqueTypes = []
    tenders.each do |tender|
      @uniqueTypes.push(tender.tender_type)
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
    @globalCpvGroups = []
		@userCpvGroups = []
    if profileAccount 
      profileAccount.cpvGroups.each do |group|
        @globalCpvGroups.push(group)
      end
      if user_signed_in?
        current_user.cpvGroups.each do |group|
          @userCpvGroups.push(group)
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


    majorGroups()
  end

  def buildOrganizationXmlStrings
    xmlString = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
    procurers = Organization.where(:is_procurer => true)
    xmlString += "\n"+'<procurers style="MEDIUM">'
    procurers.each do |proc|
      name = proc.name
      name.gsub!("&", "&amp;")
      xmlString += "\n"+'<Organization>'
      xmlString += "\n"+'<Name>'+name+'</Name>'
      xmlString += "\n"+'</Organization>'
    end
    xmlString += "\n"+'</procurers>'
    File.open("app/assets/data/procurers.xml", "w+") do |file|
      file.write(xmlString)
    end

    xmlString = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
    suppliers = Organization.where(:is_bidder => true)
    xmlString += "\n"+'<suppliers style="MEDIUM">'
    suppliers.each do |supplier|
      name = supplier.name
      name.gsub!("&", "&amp;")
      xmlString += "\n"+'<Organization>'
      xmlString += "\n"+'<Name>'+name+'</Name>'
      xmlString += "\n"+'</Organization>'
    end
    xmlString += "\n"+'</suppliers>'
    File.open("app/assets/data/suppliers.xml", "w+") do |file|
      file.write(xmlString)
    end
  end
end 
