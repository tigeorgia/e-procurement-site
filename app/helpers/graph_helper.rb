module GraphHelper
  
  def createTreeGraphStringFromAgreements( agreements )
    cpvTree = []
    agreements.each do |key, agreement|
      cpvTree.push( agreement )
    end

    jsonString = ""
    if cpvTree.length > 0
      #lets make a tree out of our CPV codes
      root = { :name => "cpv", :code => 00000000, :children => [] }
      cpvTree.sort! {|x,y| x[:code] <=> y[:code] }
      File.open("raw", 'w') {|f| f.write(cpvTree) }
      root = createTree( root, cpvTree )
      File.open("tree", 'w') {|f| f.write(root) }
      root = createUndefinedCategories( root )
      File.open("undef", 'w') {|f| f.write(root) }
      calcParentVal( root )
      File.open("parent", 'w') {|f| f.write(root) }
      jsonString = createJsonString( root, jsonString )
      File.open("jsonstr", 'w') {|f| f.write(jsonString) }
      jsonString.chop!
    end
    return jsonString
  end



  def createTree( root, list )
    prev = root
    parent = root

    list.each do |item|
      node = item
      if isChild(prev, node)
        parent = prev
      end
      if not isChild(parent, node)
        parent = root
      end
      
      parent[:children].push(node)
      prev = node  
    end
    return root
  end

  def countZeros( string )
    count = 0
    pos = string.length
    while pos > 0
      if string[pos-1] == '0'
        count = count +1
      else
        break
      end
      pos = pos - 1
    end
    return count
  end

  def isChild(parent, node)
    if parent[:name] == "cpv" 
      return true
    elsif parent[:code] == node[:code]
      return false
    else
      digits = countZeros(parent[:code])
      parentString = parent[:code]
      subParent = parentString[0, parentString.length-digits]
      codeString = node[:code]
      subCode = codeString[0, codeString.length-digits]
      return subParent == subCode
    end
  end


  #make parent values the sum of all child values
  def calcParentVal( root )
    if root[:children].length == 0
      return root[:value]
    else
      root[:children].each do |child|
        root[:value] += calcParentVal( child )
      end
      return root[:value]
    end
  end

  #pass parent category values down into new uncategorised childs
  def createUndefinedCategories( root )
    if not root[:value]
      root[:value] = 0
    end

    if root[:children].length > 0
      uncategorised = root[:value]
      if uncategorised > 0
        root[:children].push( { :name => "Not Specified", :value => uncategorised, :code => root[:code], :children => [] } )
      end
      root[:value] = 0
      root[:children].each do |child|
        createUndefinedCategories(child)
      end
    end
    return root
  end

  def createJsonString( root, jsonString )
    jsonString +="{"
    jsonString += '"name": ' + '"'+root[:name]+'"'+','
    jsonString += '"value": ' + root[:value].to_s+','
    jsonString += '"code": ' + root[:code].to_s+','
 
    if root[:children].length > 0
      jsonString += '"children": ['
      root[:children].each do |child|
        jsonString += createJsonString( child, "" )
      end
      jsonString += ']'
    end
    jsonString += "},"
    return jsonString
  end
end