module Updateable 

  def findDifferences(item, additionalIgnores = [])
    differences = []
    ignoreAttributes = ["id", "created_at", "updated_at"]
    additionalIgnores.each do |ignore|
      ignoreAttributes.push(ignore)
    end

    item.attributes.each do |attribute|
      ignoreAttributes.each do |ignore|
        if ignore == attribute[0]
          next
        end
      end

      if attribute[1] != self.attributes[attribute[0]]
        differences.push(attribute[0])
      end
    end
    return differences
  end

  def copyItem(item, additionalIgnores = [])
    ignoreAttributes = ["id"]
    additionalIgnores.each do |ignore|
      ignoreAttributes.push(ignore)
    end
    item.attributes.each do |attribute|
      ignoreAttributes.each do |ignore|
        if ignore == attribute[0]
          next
        end
      end
      #puts attribute[0].to_s
      #puts "OLD: "+ self.attributes[attribute[0]].to_s
      #puts "NEW: "+attribute[1].to_s
      write_attribute(attribute[0], attribute[1])
      #puts "AFTERSAVE: "+ self.attributes[attribute[0]].to_s
    end
    self.save
   end
end