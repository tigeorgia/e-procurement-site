#!/bin/env ruby
# encoding: utf-8

module ScraperFile

  FILE_TENDER = "tenders.json"
  FILE_ORGANISATIONS = "organisations.json"
  FILE_TENDER_BIDDERS = "tenderBidders.json"
  FILE_TENDER_AGREEMENTS = "tenderAgreements.json"
  FILE_TENDER_DOCUMENTS = "tenderDocumentation.json"
  FILE_TENDER_CPV_CODES = "tenderCPVCode.json"
  FILE_WHITE_LIST = "whiteList.json"
  FILE_BLACK_LIST = "blackList.json"
  FILE_COMPLAINTS = "complaints.json"
  FILE_SCRAPE_INFO = "scrapeInfo.txt"
  FILE_SIMPLIFIED_PROCUREMENTS = "simplified_procurements.json"
  BOM = "\uFEFF" #Byte Order Mark

  require 'csv'
  require 'json'
  require "query_helper"
  require "translation_helper"
  require "aggregate_helper"

  def self.cleanOldData(mode)
    if mode == 0
      Rails.logger.info "cleaning tender data"
      oldTenders = Tender.where(:dataset_id => @newDataset)
      oldTenders.find_each do |tender|
        tender.dataset_id = @liveDataset
        tender.save
      end
      Rails.logger.info "cleaning org data"
      oldOrgs = Organization.where(:dataset_id => @newDataset)
      oldOrgs.find_each do |org|
        org.dataset_id = @liveDataset
        org.save
      end
    elsif mode == 1
      Rails.logger.warn "removing incomplete tender data"
      Tender.where(:dataset_id => @newDataset).destroy_all
      Rails.logger.warn "removing incomplete org data"
      Organization.where(:dataset_id => @newDataset).destroy_all
    end

    Rails.logger.info "removing update flags"
    #remove updated/new flags
    tenders = Tender.where("updated = true OR is_new = true")
    tenders.each do |tender|
      tender.updated = false
      tender.is_new = false
      tender.save
    end

    orgs = Organization.where("updated = true OR is_new = true")
    orgs.each do |org|
      org.updated = false
      org.is_new = false
      org.save
    end

    bidders = Bidder.where("updated = true OR is_new = true")
    bidders.each do |bidder|
      bidder.updated = false
      bidder.is_new = false
      bidder.save
    end

    documents = Document.where("updated = true OR is_new = true")
    documents.each do |doc|
      doc.updated = false
      doc.is_new = false
      doc.save
    end

    agreements = Agreement.where("updated = true OR is_new = true")
    agreements.each do |agreement|
      agreement.updated = false
      agreement.is_new = false
      agreement.save
    end
  end

  # if we have an oldData set and a newDataset we can generate some info about the differences before merging the sets
  def self.diffData
    #switch all new records dataset id to the live version
    if @numDatasets > 1
      Tender.find_each(:conditions => "dataset_id = "+@newDataset.id.to_s) do |tender|
        tender.dataset_id = @liveDataset.id
        tender.save
      end

      Organization.find_each(:conditions => "dataset_id = "+@newDataset.id.to_s) do |organization|
        organization.dataset_id = @liveDataset.id
        organization.save
      end
    end
  end

  def self.processTenders
    tender_file_path = "#{Rails.root}/public/system/#{FILE_TENDER}"
    File.open(tender_file_path, "r") do |infile|
      count = 0
      Tender.transaction do
        while(line = infile.gets)
          count = count + 1
          item = JSON.parse(line)
          tender = Tender.new
          # basic tender info
          if count%100 == 0
            puts "tender: #{count}"
          end
          tender.url_id = item["tenderID"]
          tender.dataset_id = @newDataset.id
          tender.tender_type = self.cleanString(item["tenderType"])

          tender.tender_registration_number = item["tenderRegistrationNumber"]
          tender.tender_status = self.cleanString(item["tenderStatus"])
          tender.tender_announcement_date = Date.parse(item["tenderAnnouncementDate"])
          tender.bid_start_date = Date.parse(item["bidsStartDate"])
          tender.bid_end_date = Date.parse(item["bidsEndDate"])
          tender.estimated_value = item["estimatedValue"]
          tender.cpv_code = item["cpvCode"].split("-")[0]
          tender.addition_info = item["info"]
          tender.units_to_supply = item["amountToSupply"]
          tender.supply_period = item["supplyPeriod"]
          tender.offer_step = item["offerStep"]
          tender.guarantee_amount = item["guaranteeAmount"]
          tender.guarantee_period = item["guaranteePeriod"]
          tender.num_bids = 0
          tender.num_bidders = 0

          organization = Organization.where("organization_url = ?",item["procuringEntityUrl"]).first
          if organization
            tender.procurring_entity_id = organization.id
            tender.procurer_name = organization.name

            if !organization.is_procurer
              organization.is_procurer = true
              organization.save
            end
          end
          #is there an old tender with this url?
          oldTender = nil
          if @numDatasets > 1
            #look at previous scraped data and see if we have the same tender
            oldTender = Tender.where(:url_id => tender.url_id,:dataset_id => @liveDataset.id).first
          end

          if oldTender
            #see if we should update this tender at all
            if oldTender.updated_at < @scrapeTime
              #ignore all meta data when comparing
              ignores = ["num_bids","num_bidders","contract_value","winning_org_id",
                         "risk_indicators","procurer_name","supplier_name","sub_codes"]

              differences = oldTender.findDifferences(tender,ignores)
              if differences.length > 0
                #check for tender watches
                watch_tenders = WatchTender.where(:tender_url => tender.url_id)
                if watch_tenders.count > 0
                  #store changed fields in hash
                  hash = ""
                  differences.each do |difference|
                    hash += difference[:field].to_s+"/"+difference[:old].to_s+"#"
                  end
                  watch_tenders.each do | watch |
                    watch.diff_hash = hash
                    watch.has_updated = true
                    watch.last_data_update = @liveDataset.data_valid_from
                    watch.save
                  end
                end
                oldTender.copyItem(tender)
                puts "updating tender: " + oldTender.url_id.to_s
                oldTender.updated = true
                oldTender.save

              else
                puts "tender updated after this scrape will NOT update #{oldTender.url_id.to_s}"
              end
            else
              puts "no changes to tender: " + oldTender.url_id.to_s
            end
          else
            tender.is_new = true
            puts "saving new tender: " + tender.url_id.to_s
            tender.save
            procurerWatches = ProcurerWatch.where(:procurer_id => organization.id)
            procurerWatches.each do |watch|
              newTenderStr = tender.id.to_s+"tender#"
              puts "storing hash" + newTenderStr
              if watch.diff_hash
                watch.diff_hash += newTenderStr
              else
                watch.diff_hash = newTenderStr
              end
              watch.has_updated = true
              watch.last_data_update = @liveDataset.data_valid_from
              watch.save
            end
          end
        end #while
      end#transaction
    end#file
  end #processTenders

  def self.testDifferences
    tender_file_path = "#{Rails.root}/public/system/testdiff.json"

    File.open("#{Rails.root}/public/system/scrapeInfo.txt", "r") do |info|
      #time should be on first line
      scrapeStartTime = info.gets
      @scrapeTime = DateTime.parse(scrapeStartTime)
    end

    File.open(tender_file_path, "r") do |infile|
      count = 0
      while(line = infile.gets)
        count = count + 1
        item = JSON.parse(line)
        tender = Tender.new
        # basic tender info
        tender.url_id = item["tenderID"]
        #tender.dataset_id = @newDataset.id
        tender.tender_type = self.cleanString(item["tenderType"])

        tender.tender_registration_number = item["tenderRegistrationNumber"]
        tender.tender_status = self.cleanString(item["tenderStatus"])
        tender.tender_announcement_date = Date.parse(item["tenderAnnouncementDate"])
        tender.bid_start_date = Date.parse(item["bidsStartDate"])
        tender.bid_end_date = Date.parse(item["bidsEndDate"])
        tender.estimated_value = item["estimatedValue"]
        tender.cpv_code = item["cpvCode"].split("-")[0]
        tender.addition_info = item["info"]
        tender.units_to_supply = item["amountToSupply"]
        tender.supply_period = item["supplyPeriod"]
        tender.offer_step = item["offerStep"]
        tender.guarantee_amount = item["guaranteeAmount"]
        tender.guarantee_period = item["guaranteePeriod"]
        tender.num_bids = 0
        tender.num_bidders = 0

        organization = Organization.where("organization_url = ?",item["procuringEntityUrl"]).first
        if organization
          tender.procurring_entity_id = organization.id
          tender.procurer_name = organization.name
        end

        #is there an old tender with this url?
        oldTender = nil

        #look at previous scraped data and see if we have the same tender
        oldTender = Tender.where(:url_id => tender.url_id,:dataset_id => 1).first
        puts "old tender was last updated at #{oldTender.updated_at}"

        if oldTender
          #see if we should update this tender at all
          if oldTender.updated_at < @scrapeTime
            puts "old tender is old"
            #ignore all meta data when comparing
            ignores = ["num_bids","num_bidders","contract_value","winning_org_id",
                       "risk_indicators","procurer_name","supplier_name","sub_codes"]

            differences = oldTender.findDifferences(tender,ignores)
            if differences.length > 0
              puts "there are differences! #{differences}"
              #check for tender watches
              watch_tenders = WatchTender.where(:tender_url => tender.url_id)
              puts "watch tender count: #{watch_tenders.count}"
              if watch_tenders.count > 0
                #store changed fields in hash
                hash = ""
                differences.each do |difference|
                  hash += difference[:field].to_s+"/"+difference[:old].to_s+"#"
                end
                watch_tenders.each do | watch |
                  puts "diff_hash: #{hash}"
                  watch.diff_hash = hash
                  watch.has_updated = true
                end
              end
            else
              puts "there is no diff. That sucks"
              puts "tender updated after this scrape will NOT update #{oldTender.url_id.to_s}"
            end
          else
            puts "old tender is not old - no changes to tender: " + oldTender.url_id.to_s
          end
        else
          tender.is_new = true
          puts "(not) saving new tender: " + tender.url_id.to_s
        end
      end #while
    end#file
  end

  def self.processOrganizations
    org_file_path = "#{Rails.root}/public/system/#{FILE_ORGANISATIONS}"
    File.open(org_file_path, "r") do |infile|
      count = 0
      Organization.transaction do
        while(line = infile.gets)
          count = count + 1
          item = JSON.parse(line)

          #don't process if we have already dealt with this org this time
          organization = Organization.where("organization_url = ? AND dataset_id = ?",item["OrgUrl"],@newDataset.id).first
          if !organization
            organization = Organization.new
            if count%100 == 0
              puts "organization: #{count}"
            end
            organization.dataset_id = @newDataset.id
            organization.organization_url = item["OrgUrl"]
            organization.code = item["OrgID"]
            organization.name = self.cleanString(item["Name"])
            organization.country = self.cleanString(item["Country"])
            organization.org_type = self.cleanString(item["Type"])
            organization.city = self.cleanString(item["city"])
            organization.address = self.cleanString(item["address"])
            organization.phone_number = item["phoneNumber"]
            organization.fax_number = item["faxNumber"]
            organization.email = self.cleanString(item["email"])
            organization.webpage = self.cleanString(item["webpage"])
            organization.is_procurer = false
            organization.is_bidder = false
            #if we have an old dataset we can check if this org has been updated
            oldOrganization = nil
            if @numDatasets > 1
              oldOrganization = Organization.where(:organization_url => organization.organization_url, :dataset_id => @liveDataset.id).first
              #this is an org update we could send email alerts here
              if oldOrganization
                suppliersWatches = SupplierWatch.where(:supplier_id => oldOrganization.id)
                procurerWatches = ProcurerWatch.where(:procurer_id => oldOrganization.id)
                watches = suppliersWatches + procurerWatches
                if watches.count > 0
                  #ignore all meta data when comparing
                  ignores = ["is_procurer", "is_bidder","translation","total_won_contract_value",
                             "total_bid_tenders","total_won_tenders","total_offered_contract_value",
                             "total_offered_tenders","total_success_tenders","bw_list"]
                  differences = oldOrganization.findDifferences(organization, ignores)
                  watches.each do |watch|
                    #set hash to empty so the orgs get cleaned out everytime before processing
                    hash = ""
                    if differences.length > 0
                      #store changed fields in hash
                      differences.each do |difference|
                        hash += difference[:field]+"/"+difference[:old]+"#"
                      end
                      watch.has_updated = true
                    end
                    watch.diff_hash = hash
                    watch.last_data_update = @liveDataset.data_valid_from
                    watch.save
                  end
                end
              end
            end
            if oldOrganization
              if oldOrganization.updated_at < @scrapeTime
                oldOrganization.copyItem(organization)
                puts "updating org url: " + oldOrganization.organization_url.to_s
                oldOrganization.updated = true
                oldOrganization.save
              end
            else
              organization.is_new = true
              organization.save
              puts "saving org: " + organization.id.to_s
              #now we know everything is sorted we can run a name translation
              self.generateOrganizationNameTranslation( organization )
            end
          end#if
        end#while
      end#transaction
    end#do
  end#process org

  def self.processBidders
    bidder_file_path = "#{Rails.root}/public/system/#{FILE_TENDER_BIDDERS}"
    File.open(bidder_file_path, "r") do |infile|
      count = 0
      batch_size = 100
      complete = false
      while(not complete)
        Bidder.transaction do
          batch_count = 0
          while(not complete and batch_count < batch_size )
            line = infile.gets
            if not line
              complete = true
              break
            end
            item = JSON.parse(line)
            bidder = Bidder.new

            tender = Tender.where(:url_id => item["tenderID"]).first
            if tender!= nil
              bidder.tender_id = tender.id
              bidder.organization_url = item["OrgUrl"]
              bidder.first_bid_amount = item["firstBidAmount"]
              begin
                bidder.first_bid_date = Date.parse(item["firstBidDate"])
              rescue
                bidder.first_bid_date = nil
              end
              bidder.last_bid_amount = item["lastBidAmount"]
              begin
                bidder.last_bid_date = Date.parse(item["lastBidDate"])
              rescue
                bidder.last_bid_date = nil
              end
              bidder.number_of_bids = item["numberOfBids"]

              organization = Organization.where("organization_url = ?",item["OrgUrl"]).first
              if organization == nil
                #wtf where is the org?
              else
                bidder.organization_id = organization.id
                if !organization.is_bidder
                  organization.is_bidder = true
                  organization.save
                end
                #see if there is already a bidding object from the same org on the tender
                oldBidder = Bidder.where(:tender_id => tender.id, :organization_id => organization.id).first
                if oldBidder
                  if oldBidder.updated_at < @scrapeTime
                    #this is a bidder update
                    oldBidder.copyItem(bidder)
                    oldBidder.updated = true
                    oldBidder.save
                  end
                else
                  #this is a new bidder
                  bidder.is_new = true
                  bidder.save
                  #see if anyone is watching this supplier
                  supplierWatches = SupplierWatch.where(:supplier_id => organization.id)
                  supplierWatches.each do |watch|
                    bidString = bidder.id.to_s+"bid#"
                    if watch.diff_hash
                      watch.diff_hash += bidString
                    else
                      watch.diff_hash = bidString
                    end
                    watch.has_updated = true
                    watch.last_data_update = @liveDataset.data_valid_from
                    watch.save
                  end
                end
                tender.save
              end#if org
            else
              #tender not found investigate later
              bidder.organization_url = item["OrgUrl"]
              puts "not found tender_url = "+item["OrgUrl"]
              bidder.tender_id = -1
              bidder.save
            end#if tender
            count = count + 1
            batch_count = batch_count + 1
          end#while
          puts "bidders: #{count}"
        end#transaction
      end
    end#file
  end#processBidders

  def self.processAgreements
    agreement_file_path = "#{Rails.root}/public/system/#{FILE_TENDER_AGREEMENTS}"
    File.open(agreement_file_path, "r") do |infile|
      count = 0
      batch_size = 100
      complete = false
      while(not complete)
        Agreement.transaction do
          batch_count = 0
          while(not complete and batch_count < batch_size )
            line = infile.gets
            if not line
              complete = true
              break
            end
            item = JSON.parse(line)
            agreement = Agreement.new
            tender = Tender.where(:url_id => item["tenderID"]).first
            if tender
              oldAgreements = Agreement.where(:tender_id => tender.id, :documentation_url => item["documentUrl"])
              if oldAgreements.count == 0
                agreement.tender_id = tender.id
                agreement.amendment_number = item["AmendmentNumber"]
                agreement.documentation_url = item["documentUrl"]

                if agreement.documentation_url == "disqualifed" or agreement.documentation_url == "bidder refused agreement"
                  #puts "disqualifed agreement"
                  #org is stored as a name not an id in this case
                  organization = Organization.where(:name => item["OrgUrl"].gsub("&amp;","&")).first
                  if organization
                    agreement.organization_url = organization.organization_url
                    agreement.organization_id = organization.id
                    agreement.amount = -1
                    agreement.currency ="NULL"
                    begin
                      agreement.start_date = Date.parse(item["StartDate"])
                    rescue
                      agreement.start_date = "NULL"
                    end
                    agreement.expiry_date = "NULL"
                  end
                else
                  #"normal agreement"
                  agreement.organization_url = item["OrgUrl"]
                  organization = Organization.where(:organization_url => item["OrgUrl"]).first
                  string_arr = item["Amount"].gsub(/\s+/m, ' ').strip.split(" ")
                  agreement.amount = string_arr[0]
                  currency = "NONE"
                  if string_arr[1]
                    currency = string_arr[1]
                  end
                  agreement.currency = currency
                  begin
                    agreement.start_date = Date.parse(item["StartDate"])
                  rescue
                    agreement.start_date = "NULL"
                  end
                  begin
                    agreement.expiry_date = Date.parse(item["ExpiryDate"])
                  rescue
                    agreement.expiry_date = "NULL"
                  end

                  #The organisation that won this contract should have bid so it should have already been created
                  #so lets check the organisation database and cross-reference the org-url to get the org-id
                  if !organization
                    #wtf where is the org?
                    puts "NO ORG: #{item['OrgUrl']}"
                  else
                    agreement.organization_id = organization.id
                    #if we have zero value we need to grab the real value from the last bid this org made
                    #since the procurer must have forgot to update the contract field
                    if agreement.amendment_number == 0 and agreement.amount == 0
                      bidObject = Bidder.where(:organization_id => organization.id, :tender_id => tender.id).first
                      if bidObject
                        agreement.amount = bidObject.last_bid_amount
                      end
                    end
                  end
                end

                agreement.is_new = true
                agreement.save
                #see if anyone is watching this supplier
                supplierWatches = SupplierWatch.where(:supplier_id => agreement.organization_id)
                supplierWatches.each do |watch|
                  agreementString = agreement.id.to_s+"agreement#"
                  if watch.diff_hash
                    watch.diff_hash += agreementString
                  else
                    watch.diff_hash = agreementString
                  end
                  watch.has_updated = true
                  watch.last_data_update = @liveDataset.data_valid_from
                  watch.save
                end
              end#if this agreement is actually new
            else
              #tender not found when it should have been
              agreement.tender_id = item["tenderID"]
              #set this to -1 so we know it isn't complete
              agreement.amendment_number = -1
              agreement.save
            end
            count = count + 1
            batch_count = batch_count + 1
          end#while
          puts "agreement: #{count}"
        end#transaction
      end#while not complete
    end#file
  end#processAgreements

  def self.addSubCPVCodes
    cpv_file_path = "#{Rails.root}/public/system/#{FILE_TENDER_CPV_CODES}"
    File.open(cpv_file_path, "r") do |infile|
      count = 0
      batch_size = 100
      complete = false
      while(not complete)
        batch_count = 0
        Tender.transaction do
          while(not complete and batch_count < batch_size )
            line = infile.gets
            if not line
              complete = true
              break
            end
            item = JSON.parse(line)
            urlID =  item["tenderID"]
            puts "codes : "+item["cpvCode"]
            tender = Tender.where(:url_id => urlID).first
            #only update if this tender needed to be updated
            if tender
              if tender.sub_codes
                tender.sub_codes = tender.sub_codes+item["cpvCode"]+"#"
              else
                tender.sub_codes = item["cpvCode"]+"#"
              end
              if count%100 == 0
                puts "cpvCode: #{count}"
              end
              tender.save
              count = count + 1
              batch_count = batch_count +1
            else
              puts "tender for subcpv not found urlID: #{urlID}"
            end
          end#while
        end#transaction
      end
    end#file
  end

  #deprecated
  def self.processCPVCodes
    cpv_file_path = "#{Rails.root}/public/system/#{FILE_TENDER_CPV_CODES}"
    File.open(cpv_file_path, "r") do |infile|
      count = 0
      batch_size = 100
      complete = false
      while(not complete)
        batch_count = 0
        TenderCpvCode.transaction do
          while(not complete and batch_count < batch_size )
            line = infile.gets
            if not line
              complete = true
              break
            end
            item = JSON.parse(line)

            #check for old codes
            oldCode = TenderCpvCode.where(:tender_id => item["tenderID"], :cpv_code => item["cpvCode"]).first
            if not oldCode
              cpvCode = TenderCpvCode.new
              tender = Tender.where("url_id = ?",item["tenderID"]).first
              cpvCode.tender_id = tender.id
              cpvCode.cpv_code = item["cpvCode"]
              cpvCode.description = item["description"]
              if count%100 == 0
                puts "cpvCode: #{count}"
              end
              cpvCode.save
            end
            count = count + 1
            batch_count = batch_count +1
          end#while
        end#transaction
      end
    end#file
  end

  def self.processDocuments
    document_file_path = "#{Rails.root}/public/system/#{FILE_TENDER_DOCUMENTS}"

    File.open(document_file_path, "r") do |infile|
      count = 0
      complete = false
      batch_size = 100
      while(not complete)
        Document.transaction do
          batch_count = 0
          while(not complete and batch_count < batch_size )
            line = infile.gets
            if not line
              complete = true
              break
            end
            item = JSON.parse(line)
            document = Document.new
            tender = Tender.where("url_id = ?",item["tenderID"]).first
            if tender
              document.tender_id = tender.id
              document.document_url = item["documentUrl"]
              document.title = item["title"]
              document.author = item["author"]
              document.date = Date.parse(item["date"])

              #if this an update to an old doc
              #remove old doc
              oldDoc = Document.where(:document_url => document.document_url).first
              if (not oldDoc) or (oldDoc and oldDoc.updated_at < @scrapeTime)
                if oldDoc
                  oldDoc.destroy
                  document.updated = true
                else
                  document.is_new = true
                end
                document.save
              end
              count = count + 1
              batch_count = batch_count +1
            end
          end#while
          puts "document: #{count}"
        end#transaction
      end#while not complete
    end #file
  end #processDocuments

  #setup cpv codes
  #go through all tenders and find all unqiue cpv codes
  def self.createCPVCodes
    TenderCpvClassifier.destroy_all
    #load the cpv codes from file
    csv_text = File.read("lib/data/cpv_data.csv")
    csv_text_geo = File.read("lib/data/cpv_data_geo.csv")
    csv = CSV.parse(csv_text)
    csv_geo = CSV.parse(csv_text_geo)

    csv.each do |pair|
      cpvCode = TenderCpvClassifier.new
      cpvCode.cpv_code = pair[0]
      cpvCode.description_english = pair[1]
      csv_geo.each do |geo_pair|
        if geo_pair[0] == cpvCode.cpv_code
          cpvCode.description = geo_pair[1]
          break
        end
      end
      cpvCode.save
    end
  end#createcpv

  def self.georgianToDate( dateString )
    elements = dateString.split()
    month = elements[1]
    monthInt = -1

    case month
      when "იანვარი"
        monthInt = "1"
      when "თებერვალი"
        monthInt = "2"
      when "მარტი"
        monthInt = "3"
      when "აპრილი"
        monthInt = "4"
      when "მაისი"
        monthInt = "5"
      when "ივნისი"
        monthInt = "6"
      when "ივლისი"
        monthInt = "7"
      when "აგვისტო"
        monthInt = "8"
      when "სექტემბერი"
        monthInt = "9"
      when "ოქტომბერი"
        monthInt = "10"
      when "ნოემბერი"
        monthInt = "11"
      when "დეკემბერი"
        monthInt = "12"
    end

    monthString = elements[2]+"/"+monthInt+"/"+elements[0]
    return Date.parse(monthString)
  end

  def self.processWhiteList
    white_list_file_path = "#{Rails.root}/public/system/#{FILE_WHITE_LIST}"
    File.open(white_list_file_path, "r") do |infile|
      WhiteListItem.transaction do
        WhiteListItem.delete_all
        while(line = infile.gets)
          item = JSON.parse(line)
          whiteListItem = WhiteListItem.new
          whiteListItem.organization_id = nil
          org = Organization.where("code = ?",item["orgID"]).first
          if org
            whiteListItem.organization_id = org.id
            org.bw_list_flag = "W"
            org.save
          end
          whiteListItem.organization_name = self.cleanString(item["orgName"])
          whiteListItem.issue_date = self.georgianToDate(item["issueDate"])
          whiteListItem.agreement_url = self.cleanString(item["agreementUrl"])
          whiteListItem.company_info_url = self.cleanString(item["companyInfoUrl"])
          whiteListItem.save
        end
      end
    end
  end

  def self.processBlackList
    black_list_file_path = "#{Rails.root}/public/system/#{FILE_BLACK_LIST}"
    File.open(black_list_file_path, "r") do |infile|
      BlackListItem.transaction do
        BlackListItem.delete_all
        while(line = infile.gets)
          item = JSON.parse(line)
          blackListItem = BlackListItem.new
          blackListItem.organization_id = nil
          org = Organization.where("code = ?",item["orgID"]).first
          if org
            blackListItem.organization_id = org.id
            org.bw_list_flag = "B"
            org.save
          end
          blackListItem.organization_name = self.cleanString(item["orgName"])
          blackListItem.issue_date = self.georgianToDate(item["issueDate"])
          blackListItem.procurer_id = nil
          procurer_name = self.cleanString(item["procurer"])
          org = Organization.where("name = ?",procurer_name).first
          if org
            blackListItem.procurer_id = org.id
          end
          blackListItem.procurer_name  = procurer_name
          blackListItem.tender_id = item["tenderID"]
          blackListItem.tender_number = item["tenderNum"]
          blackListItem.reason = item["reason"]
          blackListItem.save
        end
      end
    end
  end

  def self.processComplaints
    complaints_file_path = "#{Rails.root}/public/system/#{FILE_COMPLAINTS}"
    File.open(complaints_file_path, "r") do |infile|
      Complaint.transaction do
        Complaint.delete_all
        while(line = infile.gets)
          item = JSON.parse(line)
          complaintItem = Complaint.new
          complaintItem.organization_id = nil
          org = Organization.where("code = ?",item["orgID"]).first
          if org
            complaintItem.organization_id = org.id
          end
          complaintItem.status = self.cleanString(item["status"])
          complaintItem.tender_id = nil
          tender = Tender.where("tender_registration_number = ?", item["tenderID"]).first
          if tender
            complaintItem.tender_id = tender.id
          end
          complaintItem.complaint = self.cleanString(item["complaint"])
          complaintItem.legal_basis = self.cleanString(item["legalBasis"])
          complaintItem.demand = self.cleanString(item["demand"])
          complaintItem.save
        end
      end
    end
  end

  def self.storeTenderContractValues(tenderList)
    count = 0
    tenders = nil
    if not tenderList
      tenders = Tender.all
    else
      tenders = tenderList
    end
    tenders.each do |tender|
      count = count + 1
      if count%100 == 0
        puts "Contract Store "+count.to_s
      end
      agreements = Agreement.find_all_by_tender_id(tender.id)
      #get last agreement
      lastAgreement = nil
      agreements.each do |agreement|
        #hack for now, need to add amendment numbers to disqualifactions
        if (lastAgreement and lastAgreement.amendment_number) or (not lastAgreement) or (agreement.amendment_number and lastAgreement and lastAgreement.amendment_number and lastAgreement.amendment_number < agreement.amendment_number)
          lastAgreement = agreement
        end
      end
      if lastAgreement
        tender.contract_value = lastAgreement.amount
        tender.winning_org_id = lastAgreement.organization_id
        tender.supplier_name = Organization.find(tender.winning_org_id).name
        tender.save
      end
    end
  end

  def self.storeTenderMeta
    Tender.find_each do |tender|
      #get all bidders
      numBidders = 0
      numBids = 0
      tender.bidders.each do |bidder|
        numBids += bidder.number_of_bids
        numBidders += 1
      end
      tender.num_bids = numBids
      tender.num_bidders = numBidders
      tender.save
    end
  end

  def self.storeOrgMeta
    Organization.find_each do |org|
      #get total revenue
      revenues = AggregateCpvRevenue.where(:organization_id => org.id)
      total = 0
      revenues.each do |revenue|
        total += revenue.total_value
      end
      org.total_won_contract_value = total

      #get number of tenders bid on
      org.total_bid_tenders = Bidder.where(:organization_id => org.id).count
      #get number of tenders won
      org.total_won_tenders = Tender.where(:winning_org_id => org.id).count

      tenders_offered = Tender.where(:procurring_entity_id => org.id)
      org.total_offered_tenders = tenders_offered.count
      total_offered = 0
      successful_offered = 0
      tenders_offered.each do |offered|
        if offered.contract_value and offered.contract_value >= 0
          total_offered += offered.contract_value
          successful_offered += 1
        end
      end

      org.total_offered_contract_value = total_offered
      org.total_success_tenders = successful_offered
      org.save
    end
  end

  def self.processAggregateData
    #store data for yearly stats
    AggregateHelper.generateAndStoreAggregateData
  end#process aggregate data

  def self.createUsers
    #NEEDS TO BE REMOVED LATER
    myAdminAccount = User.where(:id => 1).first
    if not myAdminAccount
      myAdminAccount = User.create!({:email => "chris@transparency.ge", :role => "admin", :password => "password84", :password_confirmation => "password84" })
      myAdminAccount.save
    end

    #Get special profile account cpv groups
    profileAccount = User.where( :role => "profile" ).first
    if not profileAccount
      profileAccount = User.create!({:email => "profile@transparency.ge", :role => "profile", :password => "67V9vP7647VVw14", :password_confirmation => "67V9vP7647VVw14" })
      #create special cpv group
      allGroup = CpvGroup.new
      allGroup.id = 1
      allGroup.user_id = profileAccount.id
      allGroup.name = "All"
      allGroup.save
    end

    #create risky special cpv group
    if not CpvGroup.where( :id => 2).first
      risky = CpvGroup.new
      risky.id = 2
      risky.user_id = profileAccount.id
      risky.name = "Risky"
      risky.save
    end
  end

  #take a string  and remove special characters and whitespace
  def self.cleanString( string )
    string = string.gsub(",,","")
    string = string.gsub("„","")
    string = string.gsub("”","")
    string = string.gsub("'","")
    string = string.gsub('"',"")
    string = string.gsub("“",'')
    string = string.gsub("&amp;","&")
    string = string.gsub("<br>","\n")
    string = string.gsub("<span>"," ")
    string = string.strip
    return string
  end

  def self.generateRiskFactors
    #this is all done manually

    holidayIndicator = CorruptionIndicator.where(:id => 1).first
    if not holidayIndicator
      holidayIndicator = CorruptionIndicator.new
      holidayIndicator.name = "Holiday Procurement"
      holidayIndicator.id = 1
      holidayIndicator.weight = 5
      holidayIndicator.description = "This tender was announced during the holiday period which seems like a strange time to start procurements"
      holidayIndicator.save
    end

    compeitionIndicator = CorruptionIndicator.where(:id => 2).first
    if not compeitionIndicator
      compeitionIndicator = CorruptionIndicator.new
      compeitionIndicator.name = "Low Competition"
      compeitionIndicator.id = 2
      compeitionIndicator.weight = 1
      compeitionIndicator.description = "This tender only had 1 bidder while this is quite common in Georgia this could have be caused by a number of corrupt factors"
      compeitionIndicator.save
    end

    biddingIndicator = CorruptionIndicator.where(:id => 3).first
    if not biddingIndicator
      biddingIndicator = CorruptionIndicator.new
      biddingIndicator.name = "Low Price Decrease"
      biddingIndicator.id = 3
      biddingIndicator.weight = 3
      biddingIndicator.description = "When two or more companies are bidding for a contract it is expected that a bidding war should lower the price a reasonble amount this has not happened in this case"
      biddingIndicator.save
    end

    cpvRiskIndicator = CorruptionIndicator.where(:id => 4).first
    if not cpvRiskIndicator
      cpvRiskIndicator = CorruptionIndicator.new
      cpvRiskIndicator.name = "Risky Contract Type"
      cpvRiskIndicator.id = 4
      cpvRiskIndicator.weight = 1
      cpvRiskIndicator.description = "This contract has been identified as being in a procurement area that is at higher risk of corruption"
      cpvRiskIndicator.save
    end

=begin    majorPlayerIndicator = CorruptionIndicator.where(:id => 5).first
    if not majorPlayerIndicator
      majorPlayerIndicator = CorruptionIndicator.new
      majorPlayerIndicator.name = "Major players not competiting"
      majorPlayerIndicator.id = 5
      majorPlayerIndicator.weight = 2
      majorPlayerIndicator.description = "Only one major player has been a bid on this contract"
      majorPlayerIndicator.save
    end
=end

    contractAmendmentIndicator = CorruptionIndicator.where(:id => 6).first
    if not contractAmendmentIndicator
      contractAmendmentIndicator = CorruptionIndicator.new
      contractAmendmentIndicator.name = "Amendment price is above the price that of a losing bidder"
      contractAmendmentIndicator.id = 6
      contractAmendmentIndicator.weight = 2
      contractAmendmentIndicator.description = "The winner of this tender has signed an agreement or amendment that has increase the tender price above that of a bid made by a competitor."
      contractAmendmentIndicator.save
    end

    blackListedSupplierIndicatior = CorruptionIndicator.where(:id => 7).first
    if not blackListedSupplierIndicatior
      blackListedSupplierIndicatior = CorruptionIndicator.new
      blackListedSupplierIndicatior.name = "A Blacklisted Company Won the Tender"
      blackListedSupplierIndicatior.id = 7
      blackListedSupplierIndicatior.weight = 5
      blackListedSupplierIndicatior.description = "The winner of this tender has been placed on the blacklist"
      blackListedSupplierIndicatior.save
    end

    @totalIndicator = CorruptionIndicator.where(:id => 100).first
    if not @totalIndicator
      @totalIndicator = CorruptionIndicator.new
      @totalIndicator.name = "Total risk score"
      @totalIndicator.id = 100
      @totalIndicator.weight = 0
      @totalIndicator.description = "This is the total risk assessement score for this tender"
      @totalIndicator.save
    end

    #remove old flags
    TenderCorruptionFlag.delete_all

    #puts "holiday"
    self.identifyHolidayPeriodTenders(holidayIndicator)
    Rails.logger.info "competition"
    self.competitionAssessment(compeitionIndicator)
    Rails.logger.info "bidding"
    self.biddingWarAssessment(biddingIndicator)
    Rails.logger.info "risky codes"
    self.identifyRiskyCPVCodes(cpvRiskIndicator)
    #puts "Major players"
    #self.majorPlayerCompetitionAssessment(majorPlayerIndicator)
    Rails.logger.info "amendment"
    self.contractAmendmentAssessment(contractAmendmentIndicator)
    Rails.logger.info "black list"
    self.blacklistSupplierAssessment(blackListedSupplierIndicatior)

    Rails.logger.info "storing risk indicators on tenders"
    self.addRiskIndicatorsToTenders
  end

  def self.addToRiskTotal( tender, val )
    totalScore = TenderCorruptionFlag.where(:corruption_indicator_id => 100,:tender_id => tender.id ).first
    if not totalScore
      totalScore = TenderCorruptionFlag.new
      totalScore.tender_id = tender.id
      totalScore.corruption_indicator_id = @totalIndicator.id
      totalScore.value = val
    else
      totalScore.value = totalScore.value + val
    end
    totalScore.save
  end

  def self.addRiskIndicatorsToTenders()
    Tender.find_each do |tender|
      flags = TenderCorruptionFlag.where(:tender_id => tender.id)
      flagStr = nil
      flags.each do |flag|
        if flag.corruption_indicator_id < 100
          if not flagStr
            flagStr = flag.corruption_indicator_id.to_s
          else
            flagStr += "#"+flag.corruption_indicator_id.to_s
          end
        end
      end
      tender.risk_indicators = flagStr
      tender.save
    end
  end

  def self.identifyHolidayPeriodTenders(indicator)
    sql = ""
    for year in (2010..Time.now.year)
      conjuction = " OR "
      if year == 2010
        conjuction = ""
      end
      sql = sql + conjuction
      holidayStart = Date.new(year,12,30).to_s
      holidayEnd = Date.new(year+1,1,11).to_s

      sql = sql + "(tender_announcement_date BETWEEN '"+holidayStart+"' AND '"+holidayEnd+"')"
    end

    Tender.find_each(:conditions => sql) do |tender|
      corruptionFlag = TenderCorruptionFlag.new
      corruptionFlag.tender_id = tender.id
      corruptionFlag.corruption_indicator_id = indicator.id
      corruptionFlag.value = 1 # maybe certain dates within this are even worse?
      corruptionFlag.save
      self.addToRiskTotal(tender, (corruptionFlag.value*indicator.weight))
    end
  end

  def self.competitionAssessment(indicator)
    Tender.find_each(:conditions => "num_bidders = 1 AND estimated_value >= 25000") do |tender|
      corruptionFlag = TenderCorruptionFlag.new
      corruptionFlag.tender_id = tender.id
      corruptionFlag.corruption_indicator_id = indicator.id
      corruptionFlag.value = 1
      corruptionFlag.save
      self.addToRiskTotal(tender, (corruptionFlag.value*indicator.weight))
    end
  end

  def self.biddingWarAssessment(indicator)
    #get all tenders that had a bidding war
    Tender.find_each(:conditions => "num_bidders > 1") do |tender|
      #now check the lowest bid and compare this to the estimated value
      lowestBid = nil
      tender.bidders.each do |bidder|
        if not lowestBid or lowestBid > bidder.last_bid_amount
          lowestBid = bidder.last_bid_amount
        end
      end
      if lowestBid
        savingsPercentage = 1 - lowestBid/tender.estimated_value
        if savingsPercentage <= 0.02
          #risky tender!
          corruptionFlag = TenderCorruptionFlag.new
          corruptionFlag.tender_id = tender.id
          corruptionFlag.corruption_indicator_id = indicator.id
          corruptionFlag.value = 1 #could have more for %1 and %0.5 etc
          corruptionFlag.save
          self.addToRiskTotal(tender, (corruptionFlag.value*indicator.weight))
        end
      end
    end
  end

  def self.identifyRiskyCPVCodes(indicator)
    riskyGroup = CpvGroup.find(2)
    classifiers = riskyGroup.tender_cpv_classifiers
    if classifiers.length > 0
      sql = ""
      conjuction = ""
      classifiers.each do |cpv|
        sql = sql + conjuction + "cpv_code = " + cpv.cpv_code.to_s
        conjuction = " OR "
      end

      Tender.find_each(:conditions => sql) do |tender|
        corruptionFlag = TenderCorruptionFlag.new
        corruptionFlag.tender_id = tender.id
        corruptionFlag.corruption_indicator_id = indicator.id
        corruptionFlag.value = 1 #perhaps we could add different values for different codes
        corruptionFlag.save
        self.addToRiskTotal( tender, (corruptionFlag.value*indicator.weight)  )
      end
    end
  end

  def self.contractAmendmentAssessment(indicator)
    Tender.find_each(:conditions => "num_bidders > 1") do |tender|
      #look at the latest agreement and check the price vs other bidders
      if tender.contract_value and tender.contract_value > 0
        #needs atleast 1 amendment
        if tender.agreements.count > 1
          winningBidder = nil
          tender.bidders.each do |bidder|
            if bidder.organization_id == tender.winning_org_id
              winningBidder = bidder
              break
            end
          end

          if winningBidder
            tender.bidders.each do |bidder|
              #if another bidders price was lower than an amended price
              if bidder.organization_id != tender.winning_org_id
                if bidder.last_bid_amount > winningBidder.last_bid_amount and bidder.last_bid_amount < tender.contract_value
                  #risky tender!
                  corruptionFlag = TenderCorruptionFlag.new
                  corruptionFlag.tender_id = tender.id
                  corruptionFlag.corruption_indicator_id = indicator.id
                  corruptionFlag.value = 1
                  corruptionFlag.save
                  self.addToRiskTotal( tender, (corruptionFlag.value*indicator.weight)  )
                  break
                end
              end
            end
          end
        end
      end
    end
  end

  #tough one
  def self.majorPlayerCompetitionAssessment(indicator)
    puts "not done"
  end

  def self.blacklistSupplierAssessment(indicator)
    blackList = BlackListItem.select(:organization_id)
    blackListIds = []
    blackList.each do |list|
      blackListIds.push(list.organization_id)
    end
    Tender.find_each do |tender|
      if tender.winning_org_id and blackListIds.include?(tender.winning_org_id)
        #risky tender!
        corruptionFlag = TenderCorruptionFlag.new
        corruptionFlag.corruption_indicator_id = indicator.id
        corruptionFlag.value = 1
        corruptionFlag.save
        self.addToRiskTotal( tender, (corruptionFlag.value*indicator.weight)  )
      end
    end
  end

  def self.generateCompetitorData()
    orgs = {}
    Tender.find_each do |tender|
      ids = []
      winning_org_id = tender.winning_org_id
      if winning_org_id
        tender.bidders.each do |bidder|
          ids.push(bidder.organization_id)
        end
        if not orgs[winning_org_id]
          nodeID+=1
          newOrg = Organization.find(winning_org_id)
          orgs[winning_org_id] = [newOrg, nodeID,{}]
        end
        ids.each do |competitor_id|
          if not competitor_id == winning_org_id
            if not orgs[competitor_id]
              nodeID+=1
              newOrg = Organization.find(competitor_id)
              orgs[competitor_id] = [newOrg, nodeID,{}]
            end
            #create link
            if not orgs[winning_org_id][2][nodeID]
              orgs[winning_org_id][2][nodeID] = 0
            end
            orgs[winning_org_id][2][nodeID] += 1
          end#if not same org
        end#for all orgs
      end
    end#for all tenders
  end

  def self.findCompetitors
    Competitor.delete_all
    #this is going to take some memory
    companies = {}
    Tender.find_each do |tender|
      ids = []
      tender.bidders.each do |bidder|
        ids.push(bidder.organization_id)
      end
      ids.each do |org_id|
        if not companies[org_id]
          companies[org_id] = {}
        end
        ids.each do |competitor_id|
          if not competitor_id == org_id
            count = companies[org_id][competitor_id]
            if not count
              count = 0
            end
            count = count + 1
            companies[org_id][competitor_id] = count
          end#if not same org
        end#for all competitor ids
      end#for all orgs
    end#for all tenders

    def self.competitorSort(a,b)
      if a[1] < b[1]
        return 1
      else
        return -1
      end
    end

    # we now have a list of companies each with a list of companies they have competed with
    # go through each company find its top 3 competitors and store this in the db
    companies.each do |org_id, competitors|
      competitors = competitors.sort {|a,b| self.competitorSort(a,b) }
      #store top 3
      count = 0
      competitors.each do |competitor_id, value|
        count = count + 1
        if value < 2 or count > 3
          break
        end
        db_competitor = Competitor.new
        db_competitor.organization_id = org_id
        db_competitor.rival_org_id = competitor_id
        db_competitor.num_tenders = value
        db_competitor.save
      end
    end
  end

  #run on live server which contains user data
  def self.generateAlertDigests
    User.find_each do |user|

      updates = {}
      searches = self.checkSearchWatches(user)
      tenderWatches = self.checkTenderWatches(user)
      supplierWatches = self.checkSupplierWatches(user)
      procurerWatches = self.checkProcurerWatches(user)
      cpvWatches = self.checkCpvWatches(user)

      if searches.length > 0
        updates[:searches] = searches
      end
      if tenderWatches.length > 0
        updates[:tenderWatches] = tenderWatches
      end
      if supplierWatches.length > 0
        updates[:supplierWatches] = supplierWatches
      end
      if procurerWatches.length > 0
        updates[:procurerWatches] = procurerWatches
      end

      if cpvWatches.length > 0
        puts "-- #{cpvWatches.length}"
        updates[:cpvWatches] = cpvWatches
      end

      if user.email_alerts and updates.length > 0
        puts "sending digest"
        AlertMailer.daily_digest(user, updates).deliver
      end

    end
  end

  def self.checkCpvWatches(user)
    # for each user, we go through the codes of the CPV the follow
    cpvgroups = CpvGroup.where(:user_id => user.id)
    updates = []
    cpvgroups.each do |cpv_group|
      classifier = cpv_group.tender_cpv_classifiers.first
      if classifier
        updated_tenders = Tender.where("(cpv_code = ? OR sub_codes like ?) AND (updated = ? OR is_new = ?)", classifier.cpv_code, "%#{classifier.cpv_code}%", true, true)
        updated_tenders.each do |updated_tender|
          updates.push(updated_tender)
        end
      end
    end
    return updates
  end

  def self.checkTenderWatches(user)
    #go through all saved Tenders and alert user to changes
    tenders = WatchTender.where(:user_id => user.id)
    updates = []
    tenders.each do |watch_tender|
      #check to see if there are any updates
      if watch_tender.has_updated
        updates.push(watch_tender)
      end
    end
    return updates
  end

  def self.checkProcurerWatches(user)
    watches = ProcurerWatch.where(:user_id => user.id)
    updates = []
    watches.each do |watch|
      #check to see if there are any updates
      if watch.has_updated
        updates.push(watch)
      end
    end
    return updates
  end

  def self.checkSupplierWatches(user)
    #go through all saved Tenders and alert user to changes
    watches = SupplierWatch.where(:user_id => user.id)
    updates = []
    watches.each do |watch|
      #check to see if there are any updates
      if watch.has_updated
        updates.push(watch)
      end
    end
    return updates
  end

  def self.checkSearchWatches( user )
    #rerun search and check for new results
    searches = Search.where(:user_id => user.id)
    updates = []

    #now we check the files we generated before the scrape and use this to find out what is new
    tenderSearchesPath = "tenderSearches.txt"
    procurerSearchesPath = "procurerSearches.txt"
    supplierSearchesPath = "supplierSearches.txt"
    updateList = []
    searches.each do |search|
      oldCount = search.count
      results = nil
      if search.searchtype == "tender"
        queryParams = QueryHelper.buildTenderSearchParamsFromString(search.search_string)
        data = QueryHelper.buildTenderQueryData(queryParams)
        results = QueryHelper.buildTenderSearchQuery(data)
        searchPath = tenderSearchesPath
      elsif search.searchtype == "supplier"
        queryParams = QueryHelper.buildSupplierSearchParamsFromString(search.search_string)
        results, throwaway = QueryHelper.buildSupplierSearchQuery(queryParams)
        searchPath = supplierSearchesPath
      else
        queryParams = QueryHelper.buildProcurerSearchParamsFromString(search.search_string)
        results, throwaway = QueryHelper.buildProcurerSearchQuery(queryParams)
        searchPath = procurerSearchesPath
      end

      #something has been changed lets load the saved search data for this search and check the ids
      if results.count != oldCount
        data = nil
        filepath = "#{Rails.root}/pre-scrape-data/"+searchPath
        if File.exist?(filepath)
          File.open(filepath, "r") do |searchFile|
            while(line = searchFile.gets)
              item = JSON.parse(line)
              if item["id"].to_s == search.id.to_s
                data = item
                break
              end
            end
          end#file open

          newItems = []
          if data
            s = (data["items"]).to_set
            results.find_in_batches do |resultbatch|
              resultbatch.each do |result|
                if not s.include?(result.id)
                  #new item lets store it!
                  newItems.push(result.id)
                end
              end
            end
          else
            #this search must have been created while the scrape was running so no need to update it
          end

          if newItems.length > 0
            search.has_updated = true
            id_string = ""
            newItems.each do |id|
              id_string += "#"+"#{id}"
            end
            search.new_ids = id_string
            search.save
            updateList.push({:search => search,:newResults => newItems})
          end
        end
      else
        #no changes this scrape set new ids to empty
        search.new_ids = ""
        search.save
      end
    end
    return updateList
  end

  #this function is to be run by the live server as a scrape begins
  #it writes all search results to file so that after the scrape this file can be compared to the post-scrape search results
  def self.storePreScrapeSearchResultsToFile
    File.open("#{Rails.root}/pre-scrape-data/tenderSearches.txt", "w") do |tenders|
      File.open("#{Rails.root}/pre-scrape-data/procurerSearches.txt", "w") do |procurers|
        File.open("#{Rails.root}/pre-scrape-data/supplierSearches.txt", "w") do |suppliers|
          Search.all.each do | search |
            ids = []
            results = nil
            writeFile = nil
            if search.searchtype == "tender"
              queryParams = QueryHelper.buildTenderSearchParamsFromString(search.search_string)
              data = QueryHelper.buildTenderQueryData(queryParams)
              results = QueryHelper.buildTenderSearchQuery(data)
              writeFile = tenders
            elsif search.searchtype == "supplier"
              queryParams = QueryHelper.buildSupplierSearchParamsFromString(search.search_string)
              results, throwaway = QueryHelper.buildSupplierSearchQuery(queryParams)
              writeFile = suppliers
            else
              queryParams = QueryHelper.buildProcurerSearchParamsFromString(search.search_string)
              results, throwaway = QueryHelper.buildProcurerSearchQuery(queryParams)
              writeFile = procurers
            end

            results.find_in_batches do |resultbatch|
              resultbatch.each do |result|
                ids.push(result.id)
              end
            end

            searchJson = {"id" => search.id, "items" => ids}
            #save result count to the db item since we use this simple db lookup to see if we need to bother doing the more complex id checks
            search.count = results.count
            search.save
            writeFile << searchJson.to_json
            writeFile << "\n"
          end
        end
      end
    end
  end

  def self.generateOrganizationNameTranslation( organization )
=begin    orgName = organization.name
    puts "translating: " + orgName
    translations = TranslationHelper.findStringTranslations(orgName)
    organization.saveTranslations(translations)
    tenderList = Tender.where(:procurring_entity_id => organization.id)
    tenderList.each do |tender|
      tender.procurer_name += "#"+organization.translation
      tender.save
    end
    tenderList = Tender.where(:winning_org_id => organization.id)
    tenderList.each do |tender|
      tender.supplier_name += "#"+organization.translation
      tender.save
    end
=end
  end

  def self.storeUpdateTime
    File.open("#{Rails.root}/public/system/scrapeInfo.txt", "r") do |info|
      #time should be on first line
      scrapeStartTime = info.gets
      @scrapeTime = DateTime.parse(scrapeStartTime)
      #while the information is valid from when the scrape started the update time will be now when the data process is ending (sometimes up to 8 hours later) so to inform the user when they will next receive an update we need to take the time as of now and add a day
      nextEstimatedTime = DateTime.now.next_day
      @liveDataset.data_valid_from = @scrapeTime
      @liveDataset.next_update = nextEstimatedTime
      @liveDataset.save
    end
  end

  def self.createLiveTenderList
    standardNonActiveList = ["დასრულებულია უარყოფითი შედეგით","ტენდერი არ შედგა","ტენდერი შეწყვეტილია","ხელშეკრულება დადებულია"]
    consolidatedNonActiveList = standardNonActiveList + ["გამარჯვებული გამოვლენილია"]
    File.open("#{Rails.root}/public/system/stalledTenders.txt", "w+") do |stallFile|
      File.open("#{Rails.root}/public/system/liveTenders.txt", "w+") do |liveFile|
        Tender.find_each do |tender|
          oldVal = tender.inProgress
          #is of type electronic or simple electronic or procurement procedure and not completed negative and not bidding failed and not terminated and not concluded OR
          #is of type consolidated and not completed negative and not bidding failed and not terminated and not concluded and not winner revealed

          #if sub_codes not stored rescrape
          if (tender.sub_codes == nil) or (tender.tender_type != "კონსოლიდირებული ტენდერი" and not standardNonActiveList.include?(tender.tender_status)) or (tender.tender_type == "კონსოლიდირებული ტენდერი" and not consolidatedNonActiveList.include?(tender.tender_status))
            tender.inProgress = true
            liveFile.write(tender.url_id.to_s+"\n")
            #why is this tender still open after 6 months?
            if (DateTime.now - tender.tender_announcement_date).to_i > 180
              stallFile.write("https://tenders.procurement.gov.ge/public/?go="+tender.url_id.to_s+"&lang=geo"+"\n")
            end
          else
            tender.inProgress = false
          end
          if oldVal != tender.inProgress
            tender.save
          end
        end
      end
    end
  end

  def self.outputOrgRevenue
    file_path = "#{Rails.root}/public/system/numbers.txt"
    orgs = {}
    File.open(file_path, "r") do |infile|
      while(line = infile.gets)
        orgCode = line.strip()
        org = Organization.where(:code => orgCode).first
        if org and org.total_won_contract_value > 0
          orgs[org.id] = org
        end
      end
    end

    orgs = orgs.sort{ |x, y| y[1][:total_won_contract_value] <=> x[1][:total_won_contract_value] }

    csv_data = CSV.generate() do |csv|
      csv << ["Name","Code","Revenue"]
      orgs.each do |index,org|
        csv << [org.name,org.code,org.total_won_contract_value]
      end
    end
    File.open("app/assets/data/revenues.csv", "w+") do |file|
      file.write(csv_data)
    end
  end

  def buildOrganizationXmlStrings
    xmlString = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
    procurers = Organization.where(:is_procurer => true)
    xmlString += "\n"+'<procurers style="MEDIUM">'
    procurers.each do |proc|
      name = proc.name
      name.delete!('"')
      name.delete!("'")
      name.gsub!("&", "&amp;")
      xmlString += "\n"+'<Name>'+name+'</Name>'
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
      name.delete!('"')
      name.delete!("'")
      name.gsub!("&", "&amp;")
      xmlString += "\n"+'<Name>'+name+'</Name>'
    end
    xmlString += "\n"+'</suppliers>'
    File.open("app/assets/data/suppliers.xml", "w+") do |file|
      file.write(xmlString)
    end
  end

  def self.setupDB
    puts "create list of unique codes"
    self.createCPVCodes
  end

  def self.process
    start = Time.now
    I18n.locale = :en # do this so formating of floats and dates is correct when reading in json

    info_file_path = "#{Rails.root}/public/system/#{FILE_SCRAPE_INFO}"
    File.open(info_file_path, "r") do |infile|
      while(line = infile.gets)
        if line.index("StartTime: ")
          index = line.index(":") + 2
          @scrapeTime = line[index..-1].to_datetime
        end
      end
    end
    #parse orgs first so that other objects can sort out relationships
    Rails.logger.info "processing Orgs"
    self.processOrganizations
    Rails.logger.info "processing tenders"
    self.processTenders
    Rails.logger.info "processing bidders"
    self.processBidders
    Rails.logger.info "processing agreements"
    self.processAgreements
    Rails.logger.info "processing docs"
    self.processDocuments
    Rails.logger.info "processing sub cpv codes"
    self.addSubCPVCodes

    Rails.logger.info "processing white list"
    self.processWhiteList
    Rails.logger.info "processing black list"
    self.processBlackList
    Rails.logger.info "process complaints"
    self.processComplaints
  end

  #Some SPA contract agreement data is incorrect because the final bid value was never transfered to the inital contract value
  #this function attempts to fix those errors
  def self.fixAgreements
    tendersToUpdate = []
    agreements = Agreement.where(:amendment_number => 0, :amount => 0)
    agreements.each do |agreement|
      bidObject = Bidder.where(:organization_id => agreement.organization_id, :tender_id => agreement.tender_id).first
      if bidObject
        Rails.logger.info "fixing #{agreement.tender_id}"
        agreement.amount = bidObject.last_bid_amount
        agreement.save
      end
      tender = Tender.where(:id => agreement.tender_id).first
      if tender and tender.contract_value == 0
        #this tenders contract value might have been effected by this bad data
        #now that it has been fixed add it to a list to recalculate
        tendersToUpdate.push(tender)
      end
    end
    self.storeTenderContractValues(tendersToUpdate)
  end

  #this is a expensive process that will combine all tender information including bidders and agreements and store each tender on a single csv row
  def self.buildTenderInfoCSVString(ignores, filePath )
    csv_string = CSV.open(filePath,'w') do |csv|
      csv << [BOM]
      #use the first object to get the column names
      column_header = []
      maxBidderObject = Tender.order("num_bidders DESC").first
      maxBidders = maxBidderObject.num_bidders
      maxBidderObject.attributes.each do |attribute|
        if not ignores.include?(attribute[0])
          if (attribute[0] == 'cpv_code')
            column_header.push('cpv_code_and_description')
          elsif (attribute[0] == 'contract_value')
            column_header.push(attribute[0])
            column_header.push('currency')
          else
            column_header.push(attribute[0])
          end

        end
      end

      column_header.push("procurer_code")
      column_header.push("winner_code")

      column_header.push("number_of_amendments")

      for num in 0..maxBidders do
        column_header.push("bidder_"+num.to_s+"_name")
        column_header.push("bidder_"+num.to_s+"_id")
        column_header.push("bidder_"+num.to_s+"_lowest_bid")
        column_header.push("bidder_"+num.to_s+"_black_or_white")
      end

      csv << column_header
      #now go through each object and print out the column values
      Tender.find_each do |tender|
        values = []

        additionalInfo = Agreement.select("organization_id, amount, currency").where(:tender_id => tender.id, :amendment_number => 0 ).first
        if additionalInfo && additionalInfo[:organization_id]
          thisOrg = Organization.select("name").where(:id => additionalInfo[:organization_id]).first
          additionalInfo[:supplier_name] = thisOrg.name
        end

        tender.attributes.each do |attribute|
          if not ignores.include?(attribute[0])

            if (attribute[0] == "contract_value")
              amount = ''
              currency = ''

              if additionalInfo && additionalInfo[:amount] && additionalInfo[:amount] != ''
                amount = additionalInfo[:amount].to_i
              end
              if additionalInfo && additionalInfo[:currency] && additionalInfo[:currency] != ''
                if (additionalInfo[:currency] == 'NONE' || additionalInfo[:currency] == 'NULL')
                  currency = 'ლარი'
                else
                  currency = additionalInfo[:currency]
                end
              end

              values.push(amount)
              values.push(currency)

            elsif (attribute[0] == "winning_org_id")
              winning_org = ''
              if additionalInfo && additionalInfo[:organization_id] && additionalInfo[:organization_id] != ''
                winning_org = additionalInfo[:organization_id]
              end
              values.push(winning_org)
            elsif (attribute[0] == "supplier_name")
              supplier = ''
              if additionalInfo && additionalInfo[:supplier_name] && additionalInfo[:supplier_name] != ''
                supplier = additionalInfo[:supplier_name]
              end
              values.push(supplier)
            elsif (attribute[0] == "cpv_code")
              cpvcode = TenderCpvCode.where(:cpv_code => attribute[1]).first
              if cpvcode
                values.push("#{attribute[1]} - #{cpvcode.description}")
              else
                cpv_val = ''
                if attribute[1] && attribute[1] != ''
                  cpv_val = attribute[1]
                end
                values.push(cpv_val)
              end
            else
              val = ''
              if attribute[1] && attribute[1] != ''
                val = attribute[1]
              end
              values.push(val)
            end

          end
        end

        tempBidders = []
        winningCode = nil
        procurerCode = nil
        procurer = Organization.where(:id => tender.procurring_entity_id).first
        if procurer
          procurerCode = procurer.code
        end
        values.push(procurerCode)

        bidders = Bidder.where(:tender_id => tender.id)
        bidders.each do |bidder|
          org = Organization.where(:id => bidder.organization_id).first
          if org.id == tender.winning_org_id
            winningCode = org.code
          end
          tempBidders.push(org.name)
          tempBidders.push(org.code)
          tempBidders.push(bidder.last_bid_amount)
          tempBidders.push(org.bw_list_flag)
        end

        values.push(winningCode)

        amendment_count = Agreement.where(:tender_id => tender.id).count
        if amendment_count > 0
          amendment_count = amendment_count - 1
        end
        values.push(amendment_count)

        tempBidders.each do |data|
          values.push(data)
        end
        csv << values
      end
    end
  end

  def self.buildSimplifiedProcurementCsv(ignores,filepath)

    line_count = 100001
    file_index = 0

    # Now go through each object and print out the column values
    # As there are many simplified procurement, we'll perform a query for each year since 2010.
    starting_year = 2010
    final_year = Date.today.year
    for i in starting_year..final_year
      current_year = i.to_s
      puts "Processing data for year #{current_year}"
      if i < final_year
        simplified_data = SimplifiedTender.where("doc_start_date >= '#{current_year}-01-01' AND doc_start_date <= '#{current_year}-12-31' AND (contract_type = 'simplified purchase' OR contract_type IS NULL)")
      else
        simplified_data = SimplifiedTender.where("doc_start_date >= '#{current_year}-01-01' AND doc_start_date <= '#{Date.today.to_s}' AND (contract_type = 'simplified purchase' OR contract_type IS NULL)")
      end

      simplified_data.find_in_batches do |data_group|

        data_group.each do |procurement|

          if line_count > 100000

            file_index += 1
            line_count = 0

            CSV.open("#{filepath}_#{file_index}.csv",'w') do |csv|
              csv << [BOM]
              #use the first object to get the column names
              column_header = []
              simplified_procurement = SimplifiedTender.first
              simplified_procurement.attributes.each do |attribute|
                if not ignores.include?(attribute[0])
                  column_header.push(attribute[0])
                end
              end

              column_header.push('supplier_name')
              column_header.push('supplier_code')
              column_header.push('procurer_name')
              column_header.push('procurer_code')
              column_header.push('main_cpv_codes')
              column_header.push('detailed_cpv_codes')
              column_header.push('paid_amounts')

              csv << column_header
            end

          end

          values = []
          procurement.attributes.each do |attribute|
            if not ignores.include?(attribute[0])
              values.push(attribute[1])
            end
          end

          # Supplier name and code
          supplier = procurement.supplier
          if supplier.nil?
            values.push('')
            values.push('')
          else
            values.push(supplier.name)
            values.push(supplier.code)
          end

          # Procurer name and code
          procurer = procurement.procuring_entity
          if procurer.nil?
            values.push('')
            values.push('')
          else
            values.push(procurer.name)
            values.push(procurer.code)
          end

          # CPV codes tied to this simplified procurement
          main_cpv_codes_array = []
          detailed_cpv_codes_array = []
          procurement.simplified_cpvs.each do |cpv|
            # we need to get the cpv in georgian, from tender_cpv_codes
            geo_cpv_code = TenderCpvCode.where(cpv_code: cpv.code).first
            title_to_use = cpv.title
            if geo_cpv_code
              title_to_use = geo_cpv_code.description
            end
            if cpv.cpv_type == 'main'
              main_cpv_codes_array << "#{cpv.code} #{title_to_use}"
            elsif cpv.cpv_type == 'detailed'
              detailed_cpv_codes_array << "#{cpv.code} #{title_to_use}"
            end
          end

          values.push(main_cpv_codes_array.join(' - '))
          values.push(detailed_cpv_codes_array.join(' - '))

          # Paid amounts for this simplified procurement
          paid_amounts = []
          procurement.simplified_paid_amounts.each do |amount|
            paid_amounts << "#{amount.amount_paid} (#{amount.amount_date})"
          end

          values.push(paid_amounts.join(' - '))

          CSV.open("#{filepath}_#{file_index}.csv",'a') do |csv|
            csv << values
            line_count += 1
          end

        end

      end

    end

  end

  def self.generate_procurement_csv_file
    buildSimplifiedProcurementCsv(['created_at','updated_at'],'AllSimplifiedProcurements')
  end


  def self.cleanOrgNames
    Organization.all.each do |org|
      rawName = org.name
      org.name = self.cleanString(rawName)
      if rawName != org.name
        org.save
      end
    end
  end

  def self.generateMetaData
    Rails.logger.info "setting up users"
    self.createUsers

    self.storeTenderMeta
    Rails.logger.info "generating aggregate data"
    self.processAggregateData
    Rails.logger.info "storing org meta"
    self.storeOrgMeta

    Rails.logger.info "finding competitors"
    self.findCompetitors
    Rails.logger.info "finding corruption"
    self.generateRiskFactors

    #self.buildTenderInfoCSVString(["addition_info", "units_to_supply", "supply_period"], "AllTenders.csv" )
    #self.buildOrganizationXmlStrings
  end

  def self.processScrape
    @numDatasets = Dataset.find(:all).count
    @liveDataset = nil
    @newDataset = nil
    #if we have 1 dataset already lets create a new one to hold the new data
    if @numDatasets == 1
      @liveDataset = Dataset.find(1)
      @newDataset = Dataset.new
      #this won't be live until we do our diff
      @newDataset.is_live = false
      @newDataset.save
    elsif @numDatasets > 1
      #if we already have 2 datasets lets use the second dataset as our temp storage id
      @liveDataset = Dataset.find(1)
      @newDataset = Dataset.find(2)
    else
      #we don't have any datasets this is a clean database so lets create the primary dataset and make it live
      @newDataset = Dataset.new
      @newDataset.is_live = true
      @newDataset.save
      @liveDataset = @newDataset
    end
    #update dataset num
    @numDatasets = Dataset.find(:all).count

    #destroy any left over data from last process
    #anything left with a dataset_id the same as newDataset mustn't have been processed fully
    self.cleanOldData(1)

    Rails.logger.info "storing update time"
    self.storeUpdateTime

    Rails.logger.info "processing json"
    self.process
    Rails.logger.info "diffing"
    self.diffData
    Rails.logger.info "storing tender results"
    tenderList = Tender.where("updated = true OR is_new = true")
    self.storeTenderContractValues(tenderList)
    self.fixAgreements
    self.generateMetaData

    Rails.logger.info "creating list of live tenders"
    self.createLiveTenderList

    Rails.logger.info "processScrape - Done."

  end

  #function hooked up to the rake task testProcess
  #fill this with function to test
  def self.testProcess
    @liveDataset = Dataset.find(1)
    @newDataset = Dataset.find(2)
    @numDatasets = Dataset.find(:all).count
    self.cleanOrgNames
  end

  def self.generateBulkTenderData
    self.buildTenderInfoCSVString(["addition_info", "units_to_supply", "supply_period"], "AllTenders.csv" )
  end

  # looping over all simplified procurement files in the folder
  def self.importSimplifiedProcurementJsonFiles

    filesFolder = "#{Rails.root}/public/system"

    Dir.glob( "#{filesFolder}/*.json") do |fileName|

      puts "\n\n----Importing #{fileName}\n\n"

      self.importSimplifiedProcurement( fileName)

    end

  end

  def self.setProcurerSupplierToProcurement(tender_line, simplified_tender)
    if simplified_tender.supplier_id.nil?
      # Referencing supplier
      supplier_info = tender_line['pSupplier']
      supplier_code = supplier_info[1]
      supplier = Organization.where(code: supplier_code).first
      if supplier.nil?
        # We're creating this new organization
        #puts "Creating supplier '#{supplier_code}' name: #{supplier_info[0]}"
        supplier = Organization.new(organization_url: '999999', code: supplier_code, name: supplier_info[0])
        supplier.save
      end
      # we're referencing this supplier in simplified_tender table
      simplified_tender.supplier_id = supplier.id
    end

    if simplified_tender.procuring_entity_id.nil?
      # Referencing procuring entity
      procurer_info = tender_line['pProcuringEntities']
      procurer_code = procurer_info[2]
      procurer = Organization.where(code: procurer_code).first
      if procurer.nil?
        # We're creating this new organization
        #puts "Creating procurer '#{procurer_code}' name: #{procurer_info[0]}"
        procurer = Organization.new(organization_url: '999999', code: procurer_code, name: procurer_info[0])
        procurer.save
      end
      # we're referencing this supplier in simplified_tender table
      simplified_tender.procuring_entity_id = procurer.id
    end

    return simplified_tender
  end

  # This method imports the simplified procurement (from a JSON file) into the MySQL tender monitor database.
  def self.importSimplifiedProcurement( simplifiedProcurementsFileName)

    simplified_procurement_file_path = "#{simplifiedProcurementsFileName}"
    count_line = 0
    File.open(simplified_procurement_file_path, "r") do |infile|

      while(line = infile.gets)

        # counter
        if (count_line % 200 == 0)
          puts "Imported #{count_line}"
        end

        # cleaning the line, if it has square brackets at the beginning/end of it.
        line.gsub!("\n",'')

        if line[0] == '['
          line[0] = ''
        end

        if line[line.length-1] == ']'
          line[line.length-1] = ''
        end

        if line[line.length-1] == ','
          line[line.length-1] = ''
        end

        # if a line has errors or is in any way faulty, we should not exit the whole program
        begin
          # this is one line in the file, one simplified procurement
          tender_line = JSON.parse(line)
        rescue
          next
        end

        if (tender_line['pContractType'] != 'simplified purchase')

          registration_number = tender_line['pCMR']

          # testing its existance
          simplified_tender = SimplifiedTender.where(registration_number: registration_number).first

          if simplified_tender && (simplified_tender.contract_signing_date.nil? || simplified_tender.contract_type.nil?)

            document_info = tender_line['pDocument']
            simplified_tender.contract_signing_date = Date.strptime(document_info[document_info.length-3],'%d.%m.%Y')
            simplified_tender.contract_type = tender_line['pContractType']
            simplified_tender.save

          end
        end

        count_line += 1

        registration_number = tender_line['pCMR']

        # testing its existance
        simplified_tender = SimplifiedTender.where(registration_number: registration_number).first

        if simplified_tender.nil?

          # It's a new simplified tender, we need to create it.
          puts "Adding '#{registration_number}'"

          simplified_tender = SimplifiedTender.new
          simplified_tender.registration_number = registration_number
          simplified_tender.status = tender_line['pStatus']
          simplified_tender.contract_type = tender_line['pContractType']
          contract_value = tender_line['pValueContract']
          if contract_value && contract_value != ''
            contract_value_array = contract_value.split(' ')
            if contract_value_array.length == 2
              simplified_tender.contract_value = contract_value_array[0]
              simplified_tender.currency = contract_value_array[1]
            end
          end
          simplified_tender.contract_value_date = Date.strptime(tender_line['pValueDate'], '%d.%m.%Y')
          document_info = tender_line['pDocument']
          simplified_tender.doc_start_date = Date.strptime(document_info[document_info.length-2],'%d.%m.%Y')
          simplified_tender.doc_end_date = Date.strptime(document_info[document_info.length-1],'%d.%m.%Y')
          simplified_tender.contract_signing_date = Date.strptime(document_info[document_info.length-3],'%d.%m.%Y')
          agreement_value = tender_line['pAgreementAmount']
          if agreement_value && agreement_value != ''
            agreement_value_array = agreement_value.split(' ')
            if agreement_value_array.length == 2
              simplified_tender.agreement_amount = agreement_value_array[0]
              simplified_tender.currency = agreement_value_array[1]
            end
          end
          simplified_tender.agreement_done = tender_line['pAgreementDone']
          simplified_tender.web_id = tender_line['pWebID']
          simplified_tender.financing_source = "#{tender_line['pFinancingSource'][0]} (#{tender_line['pFinancingSource'][1]})"
          simplified_tender.procurement_base = tender_line['pProcurementBase']

          simplified_tender = setProcurerSupplierToProcurement(tender_line,simplified_tender)

          if simplified_tender.save

            tender_id = simplified_tender.id

            # Once the simplified procurement is saved, we can now create the associated main CPVs.
            cpv_info = tender_line['pCPVCodesMain']
            cpv_info.each do |cpv|
              cpv_split = cpv.split(' - ')
              if cpv_split.length == 2
                simplified_cpv = SimplifiedCpv.where(code: cpv_split[0], title: cpv_split[1], cpv_type: 'main').first
                if simplified_cpv.nil?
                  simplified_cpv = SimplifiedCpv.new(title: cpv_split[1], code: cpv_split[0], cpv_type: 'main')
                  simplified_cpv.save
                else
                  simplified_cpv.update_attributes(title: cpv_split[1], code: cpv_split[0], cpv_type: 'main')
                end
                # We also make sure that the simplified tender and the cpv are linked
                simplified_cpv.simplified_tenders << simplified_tender
                simplified_cpv.save
              end
            end

            # Same thing with the detailed CPVs.
            cpv_info = tender_line['pCPVCodesDetailed']
            cpv_info.each do |cpv|
              cpv_split = cpv.split(' - ')
              if cpv_split.length == 2
                simplified_cpv = SimplifiedCpv.where(code: cpv_split[0], title: cpv_split[1], cpv_type: 'detailed').first
                if simplified_cpv.nil?
                  simplified_cpv = SimplifiedCpv.new(title: cpv_split[1], code: cpv_split[0], cpv_type: 'detailed')
                  simplified_cpv.save
                else
                  simplified_cpv.update_attributes(title: cpv_split[1], code: cpv_split[0], cpv_type: 'detailed')
                end
                # We also make sure that the simplified tender and the cpv are linked
                simplified_cpv.simplified_tenders << simplified_tender
                simplified_cpv.save
              end
            end

            # We also need to take care of paid amounts.
            paid_amounts = tender_line['pAmountPaid']
            paid_amounts_date = tender_line['pAmountPaidDate']
            paid_amounts.each_with_index do |amount, index|
              amount_date = Date.strptime(paid_amounts_date[index], '%d.%m.%Y')
              paid_amount = SimplifiedPaidAmount.where(amount_paid: amount, amount_date: amount_date, simplified_tender_id: tender_id).first
              if paid_amount.nil?
                paid_amount = SimplifiedPaidAmount.new(amount_paid: amount, amount_date: amount_date, simplified_tender_id: tender_id)
                paid_amount.save
              end
            end

            # And we finally take care of attachments.
            attachments = tender_line['pAttachments']
            attachments.each do |attachment|
              attachment_info = SimplifiedAttachment.where(simplified_tender_id: tender_id, url: attachment[0], title: attachment[1]).first
              if attachment_info.nil?
                attachment_info = SimplifiedAttachment.new(simplified_tender_id: tender_id, url: attachment[0], title: attachment[1])
                attachment_info.save
              end
            end

          else
            # We failed to create this simplified tender
            puts "ERROR: Simplified tender '#{registration_number}' failed to be saved.."
          end

        elsif simplified_tender.contract_signing_date.nil?
          # This simplified procurement already exists.
          # The contract value and the status are the 2 elements that can be amended.

          simplified_tender.status = tender_line['pStatus']
          simplified_tender.contract_value = tender_line['pValueContract']
          simplified_tender.contract_value_date = Date.strptime(tender_line['pValueDate'], '%d.%m.%Y')
          document_info = tender_line['pDocument']
          simplified_tender.contract_signing_date = Date.strptime(document_info[(document_info.length)-3],'%d.%m.%Y')

          if (simplified_tender.supplier_id.nil? || simplified_tender.procuring_entity_id.nil?)
            simplified_tender = setProcurerSupplierToProcurement(tender_line, simplified_tender)
          end

          simplified_tender = correctSupplier(tender_line, simplified_tender)

          simplified_tender.contract_type = tender_line['pContractType']
          simplified_tender.save
        end

        count_line += 1
      end

    end
    puts 'All done.'
  end

  def self.correctSupplier(tender_line, simplified_tender)

    if simplified_tender.supplier.nil?
      # Referencing supplier
      supplier_info = tender_line['pSupplier']
      supplier_code = supplier_info[1]
      supplier_name = supplier_info[0]
      supplier = Organization.where(code: supplier_code, name: supplier_name).first
      if supplier.nil?
        # We're creating this new organization
        #puts "Creating supplier '#{supplier_code}' name: #{supplier_info[0]}"
        supplier = Organization.new(organization_url: '999999', code: supplier_code, name: supplier_name)
        supplier.save
      end
      # we're referencing this supplier in simplified_tender table
      simplified_tender.supplier_id = supplier.id

    else
      saved_supplier_name = simplified_tender.supplier.name

      supplier_info = tender_line['pSupplier']
      supplier_name = supplier_info[0]
      supplier_code = supplier_info[1]

      if saved_supplier_name != supplier_name
        supplier = Organization.new(organization_url: '999999', code: supplier_code, name: supplier_name)
        supplier.save
        simplified_tender.supplier_id = supplier.id
      end
    end

    return simplified_tender

  end


  def self.modifyAmounts
    count = 0
    SimplifiedTender.find_in_batches do |group|
      group.each{ |procurement|
        contract_value = procurement.contract_value
        if contract_value && contract_value != ''
          contract_value_array = contract_value.split(' ')
          if contract_value_array.length == 2
            procurement.contract_value = contract_value_array[0]
            procurement.currency = contract_value_array[1]
          end
        end

        agreement_value = procurement.agreement_amount
        if agreement_value && agreement_value != ''
          agreement_value_array = agreement_value.split(' ')
          if agreement_value_array.length == 2
            procurement.agreement_amount = agreement_value_array[0]
            procurement.currency = agreement_value_array[1]
          end
        end

        procurement.save
        count += 1

        if count % 1000 == 0
          puts count
        end
      }
    end
  end

  def self.checkForDups
    Tender.find_each do |tender|
      count = Tender.where(:url_id => tender.url_id).count
      if count > 1
        puts "TENDER DUPE: "+tender.url_id.to_s+" COUNT = #{count}"
      end
    end

    Organization.find_each do |org|
      count = Organization.where(:organization_url => org.organization_url).count
      if count > 1
        puts "ORG DUPE: "+org.organization_url.to_s+ " COUNT = #{count}"
      end
    end
  end

  # extracting tenders which should be re-scraped because their status is not completed

  def self.extractSimplifiedProcurementsToUpdate

    filesFolder = "#{Rails.root}/public/system"

    File.open( "#{filesFolder}/tender_update.txt", "w" ) do |fileDesc|

      SimplifiedTender.where('status = ?', 'Ongoing contract').find_each do |tender|

        fileDesc.puts "#{tender.web_id}\n"

      end

      # we would also like the maximum value of web_id in the database, so we do not re-scrape the same stuff
      max_present_id = SimplifiedTender.maximum( 'web_id')

      fileDesc.puts "#{max_present_id}\n"



    end

  end

end



