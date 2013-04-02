module CpvHelper

  def self.createCPVClassifiers(destroy)
    if destroy
      TenderCpvClassifier.all.destroy
    end
    csv_text = File.read("lib/data/cpv_data.csv")
    csv = CSV.parse(csv_text)
    csv.each do |pair|
      oldCode = TenderCpvClassifier.where(:cpv_code => pair[0]).first
      if not oldCode
        code = TenderCpvClassifier.new
        code.cpv_code = pair[0]
        code.description = pair[1]
        code.description_english = pair[1]
        code.save
      end
    end#for each pair
  end

end
