module ScraperFile

  FILE_TENDER = "tenders.json"
  FILE_ORGANISATIONS = "organisations.json"
  FILE_TENDER_BIDDERS = "tenderBidders.json"
  FILE_TENDER_AGREEMENTS = "tenderAgreements.json"
  FILE_TENDER_DOCUMENTS = "tenderDocumentation.json"
  require 'csv'
  

  def self.diffData

    #delete all old data if we have a similar version of the data in the current set    

    #make the new dataset the live dataset
    if not Dataset.find(@dataset.id-1)
      #there is nothing to diff we are done
      return    
    end
    prevID = @dataset.id-1
    
    #now lets get all records from our prev dataset and compare them to our new one
    Tender.find_each(:conditions => "dataset_id = "+prevID.to_s) do |tender|

      newTender = Tender.where("url_id = ? AND dataset_id = ?",tender["url_id"],@dataset.id).first
      #What do we do if an old tender has been removed?
      if newTender
        #tender with same url found so we can remove the old one
        tender.destroy
      end 
    end       
        
=begin        #LOOK INTO THIS LATER#check to see if the data is the same
        newTender.id = tender.id
        newTender.procurring_entity_id = tender.procurring_entity_id
        newTender.dataset_id = tender.dataset_id
        newTender.created_at = tender.created_at
        newTender.updated_at = tender.updated_at
        if newTender.attributes == tender.attributes
          #the new tender is the same as the current tender, now the current tender isn't needed
          tender.destroy
        end                      
    end
=end 

    Organization.find_each(:conditions => "dataset_id = "+prevID.to_s) do |organization|
      #see if this org has changed.
      newOrganization = Organization.where("organization_url = ? AND dataset_id = ?", organization["organization_url"], @dataset.id).first
      if newOrganization
        # delete the old org
        organization.destroy
      end
    end

=begin        #check to see if data is the same
        newOrganization.id = organization.id
        newOrganization.dataset_id = organization.dataset_id
        newOrganization.created_at = organization.created_at
        newOrganization.updated_at = organization.updated_at
        if newOrganization.attributes == organization.attributes 
          #this org might be referenced by a tender as a procurrer
          #so we need to update that tender to reference the new org before deleting it
          tenders = Tender.where("procurring_entity_id = ?", organization.id)
          tenders.each do |tender|
            tender.procurring_entity_id = newOrganization.id
            tender.save
          end
          #it is now safe to destroy       
          organization.destroy
        end

      end
    end
=end


    #now make our new dataset live and switch the old dataset off
    prevDataSet = Dataset.find(prevID)
    prevDataSet.is_live = false
    prevDataSet.save
    @dataset.is_live = true
    @dataset.save
  end	


  def self.processTenders
    tender_file_path = "#{Rails.root}/public/system/#{FILE_TENDER}"
    tender_file_data = File.open(tender_file_path, "r") {|f| f.read()}

    if tender_file_data
      #clean up formatting and parse
      json_tender = JSON.parse(tender_file_data.gsub("},]", "}]"))

      json_tender.each_with_index do |item, index|
        tender = Tender.new
        Tender.transaction do
          # basic tender info
          if index%100 == 0
            puts "tender: #{index}"
          end
          tender.url_id = item["tenderID"]
          tender.dataset_id = @dataset.id
          tender.tender_type = item["tenderType"]
          tender.tender_registration_number = item["tenderRegistrationNumber"]
          tender.tender_status = item["tenderStatus"]
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

          organization = Organization.where("organization_url = ? AND dataset_id = ?",item["procuringEntityUrl"],@dataset.id).first      
          if organization             
            tender.procurring_entity_id = organization.id
            if !organization.is_procurer
              organization.is_procurer = true
              organization.save
            end
          end
          if tender.valid?
            tender.save
          else
		        raise ActiveRecord::Rollback
		        break
          end #if tender valid
        end #transaction
      end#for each json tender
    end#if data exists
  end #processTenders

  def self.processOrganizations
    org_file_path = "#{Rails.root}/public/system/#{FILE_ORGANISATIONS}"
    org_file_data = File.open(org_file_path, "r") {|f| f.read()}
    puts org_file_path
    if org_file_data   
      json_org = JSON.parse(org_file_data.gsub("},]", "}]"))
      json_org.each_with_index do |item, index|
        # if the procurer does not exist in organization yet, add it
        organization = Organization.where("organization_url = ? AND dataset_id = ?",item["OrgUrl"],@dataset.id).first
        if !organization
          organization = Organization.new
          Organization.transaction do
            if index%100 == 0
              puts "organization: #{index}"
            end
            organization.dataset_id = @dataset.id
            organization.organization_url = item["OrgUrl"]
            organization.code = item["OrgID"]
            organization.name = item["Name"]
            organization.country = item["Country"]
            organization.org_type = item["Type"]
            organization.city = item["city"]
            organization.address = item["address"]  
            organization.phone_number = item["phoneNumber"]
            organization.fax_number = item["faxNumber"]
            organization.email = item["email"]
            organization.webpage = item["webpage"]
            organization.is_procurer = false
            organization.is_bidder = false
            if organization.valid?
              organization.save
            else
		          raise ActiveRecord::Rollback
		          break
            end
          end#transaction
        end
      end #for each json org
    end #if data exists
    
  end#process org


  def self.processBidders
    bidder_file_path = "#{Rails.root}/public/system/#{FILE_TENDER_BIDDERS}" 
    bidder_file_data = File.open(bidder_file_path, "r") {|f| f.read()}
    if bidder_file_data
      json_bidders = JSON.parse(bidder_file_data.gsub("},]", "}]"))
      json_bidders.each_with_index do |item, index|
        bidder = Bidder.new
        Bidder.transaction do
          if index%100 == 0
            puts "bidder: #{index}"
          end
          tender = Tender.where("url_id = ? AND dataset_id = ?",item["tenderID"],@dataset.id).first
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
          tender.num_bids = tender.num_of_bids + bidder.number_of_bids
          tender.num_bidders = tender.num_bidders + 1
          
          organization = Organization.where("organization_url = ? AND dataset_id = ?",item["OrgUrl"],@dataset.id).first
          if !organization
            #wtf where is the org?
          else
            bidder.organization_id = organization.id
            if !organization.is_bidder
              organization.is_bidder = true
              organization.save
            end
          end
          if bidder.valid?
            bidder.save
            tender.save
          else
            raise ActiveRecord::Rollback
            break
          end
        end
      end#for each json item
    end#if data exists
    
  end#processBidders

  def self.processAgreements
    agreement_file_path = "#{Rails.root}/public/system/#{FILE_TENDER_AGREEMENTS}"
    agreement_file_data = File.open(agreement_file_path, "r") {|f| f.read()}
    if agreement_file_data
      json_agreement = JSON.parse(agreement_file_data.gsub("},]", "}]"))
      json_agreement.each_with_index do |item, index|
        agreement = Agreement.new
        Agreement.transaction do
          if index%100 == 0
            puts "agreement: #{index}"
          end
          tender = Tender.where("url_id = ? AND dataset_id = ?",item["tenderID"],@dataset.id).first
          agreement.tender_id = tender.id
          agreement.amendment_number = item["AmendmentNumber"]
          agreement.documentation_url = item["documentUrl"]
          
          if agreement.documentation_url == "disqualified" or agreement.documentation_url == "bidder refused agreement"
            organization = Organization.where("name = ? AND dataset_id = ?",item["OrgUrl"],@dataset.id).first
            agreement.organization_url = organization.organization_url
            agreement.organization_id = organization.id
            agreement.amount = item["Amount"]
            agreement.start_date = Date.parse(item["StartDate"])
            agreement.expiry_date = "NULL"
          else
            agreement.organization_url = item["OrgUrl"]
            agreement.amount = item["Amount"]
            begin
              agreement.start_date = Date.parse(item["StartDate"])
            rescue
              agreement.start_date = nil         
            end
            begin
              agreement.expiry_date = Date.parse(item["ExpiryDate"])
            rescue
              agreement.expiry_date = nil         
            end

            #The organisation that won this contract should have bid so it should have already been created
            #so lets check the organisation database and cross-reference the org-url to get the org-id
            organization = Organization.where("organization_url = ? AND dataset_id = ?",item["OrgUrl"],@dataset.id).first
            if !organization
              #wtf where is the org?
            else
              agreement.organization_id = organization.id
            end
          end
                
          if agreement.valid?
            agreement.save
          else
            raise ActiveRecord::Rollback
            break
          end
        end
      end#for each json item
    end#if data exists
    
  end#processAgreements


  def self.processDocuments
    document_file_path = "#{Rails.root}/public/system/#{FILE_TENDER_DOCUMENTS}"
    document_file_data = File.open(document_file_path, "r") {|f| f.read()}
    if document_file_data
      json_documents = JSON.parse(document_file_data.gsub("},]", "}]"))
      json_documents.each_with_index do |item, index|       
        document = Document.new
        Document.transaction do
          tender = Tender.where("url_id = ? AND dataset_id = ?",item["tenderID"],@dataset.id).first
          document.tender_id = tender.id
          document.document_url = item["documentUrl"]
          if index%100 == 0
            puts "document: #{index}"
          end
          if document.valid?
            document.save
          else
            raise ActiveRecord::Rollback
            break
          end
        end
      end #foreach document
    end #if data exists
  end #processDocuments

  #go through all tenders and find all unqiue cpv codes
  def self.createCPVCodes
    #load the cpv codes from file
    csv_text = File.read("lib/data/cpv_data.csv")
    csv = CSV.parse(csv_text)

    #change this to make a full list via scraped data
    tenders = Tender.find(:all, :select =>'distinct cpv_code')
    TenderCpvClassifier.transaction do
      TenderCpvClassifier.delete_all
      tenders.each do |tender|
        code = TenderCpvClassifier.new
        if tender.cpv_code
          data = tender.cpv_code.split("-")        
          code.cpv_code = data[0]
          code.description = data[1]
          oldEntries = 0
          if oldEntries < 1
            #no point searching for english translation if it already exists so do it now
            intCode = code.cpv_code.to_i          
            csv.each do |pair|
              if pair[0].to_i == intCode
                code.description_english = pair[1]
                break
              end
            end#for each pair
            code.save
          end#if doesn't exist
        end#if tender has cpv_code
      end#tenders
    end#transaction
  end#createcpv

  def self.processAggregateData
    #for each CPV code calculate the revenue generated for each company and store these entries in the database
    #this way when aggregate data is requested instead of running this expensive process everytime we can just look up the pre-calculated entries in the db.
  AggregateCpvRevenue.delete_all
  classifiers = TenderCpvClassifier.find(:all)
    classifiers.each do |classifier|
      puts classifier.cpv_code
      tenders = Tender.where(:cpv_code => classifier.cpv_code)
      tenders.each do |tender|      
        last = nil
        tender.agreements.each do |agreement|
          #find lastest agreement
          if not last or agreement.amendment_number > last.amendment_number
            last = agreement
          end
        end # for each agreement

        if last
          dataset = Dataset.where(:is_live => true).first
          liveDataSetID = dataset.id
          
          id = last.organization_url
          tenderValue = last.amount
          company = Organization.where(["dataset_id = ? AND organization_url = ?", liveDataSetID, id]).first
          aggregateData = AggregateCpvRevenue.where(:cpv_code => classifier.cpv_code, :organization_id => company.id).first
          if not aggregateData
            aggregateData = AggregateCpvRevenue.new
            aggregateData.organization_id = company.id
            aggregateData.cpv_code = classifier.cpv_code
            aggregateData.total_value = tenderValue
          else
            aggregateData.total_value = aggregateData.total_value + tenderValue
          end
          aggregateData.save
        end
      end
    end
  end#process aggregate data


  def self.createUsers
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
  end

  def self.generateRiskFactors
    #this is all done manually

    holidayIndicator = CorruptionIndicator.new
    holidayIndicator.name = "Holiday Procurement"
    holidayIndicator.id = 1     
    holidayIndicator.weight = 5
    holidayIndicator.description = "This tender was announced during the holiday period which seems like a strange time to start procurements"
    holidayIndicator.save

    compeitionIndicator = CorruptionIndicator.new
    compeitionIndicator.name = "Low Competition"
    compeitionIndicator.id = 2     
    compeitionIndicator.weight = 1
    compeitionIndicator.description = "This tender only had 1 bidder while this is quite common in Georgia this could have be caused by a number of corrupt factors"
    compeitionIndicator.save
    
    biddingIndicator = CorruptionIndicator.new
    biddingIndicator.name = "Tame bidding exchange"
    biddingIndicator.id = 3     
    biddingIndicator.weight = 3
    biddingIndicator.description = "When two or more companies are bidding for a contract it is expected that a bidding war should lower the price a reasonble amount this has not happened in this case"
    biddingIndicator.save

    cpvRiskIndicator = CorruptionIndicator.new
    cpvRiskIndicator.name = "Risky Contract Type"
    cpvRiskIndicator.id = 4     
    cpvRiskIndicator.weight = 1
    cpvRiskIndicator.description = "This contract has been identified as being in a procurement area that is at higher risk of corruption"
    cpvRiskIndicator.save

    majorPlayerIndicator = CorruptionIndicator.new
    majorPlayerIndicator.name = "Major players not competiting"
    majorPlayerIndicator.id = 5     
    majorPlayerIndicator.weight = 2
    majorPlayerIndicator.description = "Only one major player has been a bid on this contract"
    majorPlayerIndicator.save


    self.identifyHolidayPeriodTenders(holidayIndicator)   
    self.competitionAssessment(compeitionIndicator)
    self.biddingWarAccessmentbiddingIndicator)
    self.identifyRiskyCPVCodes(cpvRiskIndicator)
    self.majorPlayerCompetitionAssessment(majorPlayerIndicator)
  end

  def identifyHolidayPeriodTenders(indicator)
    sql = "dataset_id = " + @dataset.id.first
    for year in (2010..Time.now.year)
      conjuction = " OR "
      if year == 2010
        conjuction = " AND "
      end
      sql = sql + conjuction
      holidayStart = Date.new(year,12,30)
      holidayEnd = Date.new(year+1,1,11)

      sql = sql + "(tender_announcement_date > "+holidayStart+" AND tender_announcement_date < "+holidayEnd+")"
    end

    riskyTenders = Tender.where(sql).find_each do |tender|
      corruptionFlag = TenderCorruptionFlag.new
      corruptionFlag.tender_id = tender.id
      corruptionFlag.corruption_indicator_id = indicator.id
      corruptionFlag.value = 1 # maybe certain dates within this are even worse?
      corruptionFlag.save
    end
  end
  
  def competitionAssessment(indicator)
    Tender.where(:dataset_id => @dataset.id.first, num_bidders => 1).find_each do |tender|
      corruptionFlag = TenderCorruptionFlag.new
      corruptionFlag.tender_id = tender.id
      corruptionFlag.corruption_indicator_id = indicator.id
      corruptionFlag.value = 1
      corruptionFlag.save
    end
  end

  def biddingWarAccessment(indicator)
    #get all tenders that has a bidding war
    Tender.where(:dataset_id => @dataset.id.first, :num_bidders => 1).find_each do |tender|
      #now check the winning bid and compare this to the estimated value
      winningVal = nil
      tender.agreements.each do |agreement|
        if agreement.amendment_number == 0
          winningVal = agreement.amount
          break
        end
      end
      if winningVal
        savingsPercentage = 1 - winningVal/tender.estimated_value
        if savingsPercentage <= 0.02
          #risky tender!
          corruptionFalg = TenderCorruptionFlag.new
          corruptionFlag.tender_id = tender.id
          corruptionFlag.corruption_indicator_id = indicator.id
          corruptionFlag.value = 1 #could have more for %1 and %0.5 etc
          corruptionFlag.save
        end
      end
    end
  end

  def identifyRiskyCPVCodes(indicator)
  end

  #tough one
  def majorPlayerCompetitionAssessment(indicator)
  end


=begin	def self.createCPVTree

		def countZeros( string )
		  count = 0
		  pos = string.length
		  while pos > 0
		    if string[pos-1] == '0'
		      count = count +1
		    else
		      break
		    end
		    pos = pos - 1
		  end
		  return count
  	end

		def sortDescending( x, y )
			if x.cpv_code.to_i < y.cpv_code.to_i
				return -1
			else
				return 1
			end
  	end

		def isChild(parent, node)
		  if parent[:item] == nil 
		    return true
		  else
		    digits = countZeros(parent[:item].cpv_code)
		    parentString = parent[:item].cpv_code
		    subParent = parentString[0, parentString.length-digits]
		    codeString = node[:item].cpv_code
		    subCode = codeString[0, codeString.length-digits]
		    return subParent == subCode
		  end
		end

		def createTree( root, list )
		  prev = root
		  parent = root

		  list.each do |item|
		    node = { :item => item, :children => [] }
		    if isChild(prev, node)
		      parent = prev
		    end
		    if not isChild(parent, node)
		      parent = root
		    end
		      
		    parent[:children].push(node)
		    prev = node  
		  end
		end

		def printTree( file, root )
		  if root[:item]
		    file.syswrite(root[:item].description)
		  end

		  root[:children].each do |child|
		    printTree( file, child )
		  end
		end

		def printNode( root )
		  treeFile = File.new("cpvTree", "w+")
		  if treeFile
		    printTree(treeFile, root )
		  end
		  treeFile.close
		end

    cpvs = TenderCpvClassifier.find(:all)
    root = { :item => nil, :children => [] }
    cpvs.sort! {|x,y| sortDescending(x,y) }
    createTree( root, cpvs )
    printTree( root )
	end
=end
  def self.process
    start = Time.now
    msg = nil
    msgs = []
    I18n.locale = :en # do this so formating of floats and dates is correct when reading in json
    
    #parse orgs first so that other objects can sort out relationships
    puts "processing Orgs"
    self.processOrganizations
    puts "processing tenders"  
    self.processTenders
    puts "processing bidders"
    self.processBidders
    puts "processing agreements"
    self.processAgreements
    puts "processing docs"
    self.processDocuments
    puts "generate cpv codes"
    self.createCPVCodes
    puts "generating aggregate data"
    self.processAggregateData
    puts "setting up users"
    self.createUsers
    puts "finding corruption"
    self.generateRiskFactors
  end

  def self.processFullScrape
    #lets create a new dataset record
    @dataset = Dataset.new
    #this won't be live until we do our diff
    @dataset.is_live = false
    @dataset.save
    puts "processing json"
    self.process
    puts "diffing"
    #for now diff only removes the old dataset once we are sure the scrape went smoothly
    self.diffData
  end

  def self.processIncrementalScrape
    #get current dataset
    @dataset = Dataset.last
    self.process
  end

  def self.buildUserDataOnly
    puts "generate cpv codes"
    self.createCPVCodes
    puts "generating aggregate data"
    self.processAggregateData
    puts "setting up users"
    self.createUsers
  end
end
