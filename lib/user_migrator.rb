module UserMigrator 
  def self.createMigrationFile   
    File.open("user_data.txt", "w+") do |infoFile|   
      User.find_each do |user|
        #save cpv group data
        groups = CpvGroup.where(:user_id => user.id)
        groups.each do |group|
          classifiers = group.tender_cpv_classifiers
          classifiers.each do |classifier|
            code = classifier.cpv_code
            infoFile.puts("CPV,"+user.id.to_s+","+group.id.to_s+","+code)
          end
        end
=begin        #this shouldnt be needed since we store the url_id which will be the same anyways
        tenderWatches = WatchTender.where(:user_id => user.id)
        tenderWatches.each do |watch|
          tender = Tender.where(:url_id => watch.tender_url).first
          infoFile.puts("TenderWatch,"+user.id.to_s+","+tender.tender_registration_number)
        end
=end
          
        procWatches = ProcurerWatch.where(:user_id => user.id)
        procWatches.each do |watch|
          org = Organization.find(watch.procurer_id)
          infoFile.puts("ProcurerWatch,"+user.id.to_s+","+watch.id.to_s+","+org.organization_url)
        end
        supplierWatches = SupplierWatch.where(:user_id => user.id)
        supplierWatches.each do |watch|
          org = Organization.find(watch.supplier_id)
          infoFile.puts("SupplierWatch,"+user.id.to_s+","+watch.id.to_s+","+org.organization_url)
        end      
      end
    end
  end

  def self.migrate
    #lets nuke the cpv classifiers associations
    CpvGroup.find_each do |group|
      group.tender_cpv_classifiers.clear
    end
    File.open("user_data.txt", "r") do |infoFile|
      while line = infoFile.gets
        item = line.split(",")
        type = item[0]
        userID = item[1].to_i
        if type == "CPV"         
          groupID = item[2].to_i
          code = item[3]
          cpvGroup = CpvGroup.find(groupID)
          classifier = TenderCpvClassifier.where("cpv_code = "+code.to_s).first
          if classifier
            cpvGroup.tender_cpv_classifiers << classifier
          end
          cpvGroup.save
        elsif type == "ProcurerWatch"
          procID = item[2].to_i
          watch = ProcurerWatch.where(:id => procID).first
          procurer = Organization.where(:organization_url => item[3].to_i).first
          if procurer
            watch.procurer_id = procurer.id
          end
          watch.save
        elsif type == "SupplierWatch"
          supplierID = item[2].to_i
          watch = SupplierWatch.where(:id => supplierID).first
          supplier = Organization.where(:organization_url => item[3].to_i).first
          if supplier
            watch.supplier_id = supplier.id
          end
          watch.save
        end
      end
    end
  end
end
