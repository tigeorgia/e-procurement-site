module Updateable 

  def findDifferences(item, additionIgnores = [])
    differences = []
    ignoreAttributes = ["id", "created_at", "updated_at"]
    additionIgnores.each do |ignore|
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

  def copyItem(item, additionIgnores = [])
    ignoreAttributes = ["id"]
    additionIgnores.each do |ignore|
      ignoreAttributes.push(ignore)
    end
    item.attributes.each do |attribute|
      ignoreAttributes.each do |ignore|
        if ignore == attribute[0]
          next
        end
      end
      self.attributes[attribute[0]] = attribute[1] 
    end
    self.save
   end
end
