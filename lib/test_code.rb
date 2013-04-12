module TestFile
  require "translation_helper"
  require "aggregate_helper"
  require "cpv_helper"

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
    self.addRiskIndicatorsToTenders()
  end

end

