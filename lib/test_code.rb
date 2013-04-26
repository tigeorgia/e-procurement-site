module TestFile
  require "translation_helper"
  require "aggregate_helper"
  require "cpv_helper"



  def self.processProcAggregates
    ProcurerCpvRevenue.delete_all
    classifiers = TenderCpvClassifier.find(:all)
    classifiers.each do |classifier|
      puts classifier.cpv_code
      Tender.find_each(:conditions => "cpv_code = " + classifier.cpv_code) do |tender|
        if tender.contract_value and tender.contract_value > 0
          tenderValue = tender.contract_value
          procurer = Organization.find(tender.procurring_entity_id)
          if procurer
            aggregateData = ProcurerCpvRevenue.where(:cpv_code => classifier.cpv_code, :organization_id => procurer.id).first
            if not aggregateData
              aggregateData = ProcurerCpvRevenue.new
              aggregateData.organization_id = procurer.id
              aggregateData.cpv_code = classifier.cpv_code
              aggregateData.total_value = tenderValue
            else
              aggregateData.total_value = aggregateData.total_value + tenderValue
            end
            aggregateData.save
          end
        end
      end
    end
  end

  def self.cleanNames
    Organization.find_each do |org|
      name = org.name.delete('"').delete("'")
      org.name = name
      puts name
      org.save
    end
  end

  def self.storeOrgNamesOnTenders
    Tender.find_each do |tender|
      org = Organization.find(tender.procurring_entity_id)
      tender.procurer_name = org.name + "#" + org.translation
      if tender.winning_org_id
        org = Organization.find(tender.winning_org_id)
        tender.supplier_name = org.name + "#" + org.translation
      end
      tender.save
    end
  end

  def self.storeOrgMeta()
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
        if offered.contract_value and offered.contract_value > 0
          total_offered += offered.contract_value
          successful_offered += 1
        end
      end
      
      org.total_offered_contract_value = total_offered
      org.total_success_tenders = successful_offered
      org.save
    end
  end

  def self.generateOrganizationNameTranslations
    Organization.all.each do |organization|
      orgName = organization.name
      puts orgName
      if not organization.translation
        translations = TranslationHelper.findStringTranslations(orgName)
        puts "result: "
        puts translations
        organization.saveTranslations(translations)
      end
      puts "#############"
    end
  end

  def self.storeTenderContractValues()
    count = 0
    Tender.find_each do |tender|
      count = count + 1
      if count%100 == 0
        puts count.to_s
      end
      agreements = Agreement.find_all_by_tender_id(tender.id)
      #get last agreement
      lastAgreement = nil
      agreements.each do |agreement|
        if not lastAgreement or lastAgreement.amendment_number < agreement.amendment_number
          lastAgreement = agreement
        end
      end
      if lastAgreement
        tender.contract_value = lastAgreement.amount
        tender.winning_org_id = lastAgreement.organization_id
        tender.save
      end
    end
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

  #filled out with tasks to test
  def self.run
    #CpvHelper.createCPVClassifiers(false)
    #self.storeTenderContractValues()
    self.processProcAggregates()
  end

end

