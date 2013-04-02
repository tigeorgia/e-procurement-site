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


  #filled out with tasks to test
  def self.run
    CpvHelper.createCPVClassifiers(false)
  end

end

