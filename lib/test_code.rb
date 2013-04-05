module TestFile
  require "translation_helper"
  require "aggregate_helper"
  require "cpv_helper"

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
        tender.save
      end
    end
  end

  #filled out with tasks to test
  def self.run
    #CpvHelper.createCPVClassifiers(false)
    self.storeTenderContractValues()
  end

end

