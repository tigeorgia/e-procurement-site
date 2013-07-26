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
        change = {:field => attribute[0],:old => self.attributes[attribute[0]]}
        differences.push(change)
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

  def getHumanReadableAttributeName( attribute )
    if self.class.const_defined?("HUMANREADABLE")
        return self.class::HUMANREADABLE[attribute]
    end
    return nil
  end
end
