module Updateable 

  def findDifferences(item, additionalIgnores = [])
    differences = []
    ignoreAttributes = ["id", "created_at", "updated_at","dataset_id","InProgess","updated","is_new"]
    additionalIgnores.each do |ignore|
      ignoreAttributes.push(ignore)
    end

    item.attributes.each do |attribute|
      if ignoreAttributes.include?(attribute[0])
        next
      end
      if attribute[1] != self.attributes[attribute[0]]
        puts "old #{self.attributes[attribute[0]]}" 
        puts "new #{attribute[1]}"
        differences.push(attribute[0])
      end
    end
    return differences
  end

  def copyItem(item, additionalIgnores = [])
    ignoreAttributes = ["id","created_at","dataset_id"]
    additionalIgnores.each do |ignore|
      ignoreAttributes.push(ignore)
    end
    item.attributes.each do |attribute|
      if ignoreAttributes.include?(attribute[0])
        next
      end
      write_attribute(attribute[0], attribute[1])
    end
    self.save
  end
end
