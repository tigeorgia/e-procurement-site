class CpvTreeController < ApplicationController
  include ApplicationHelper
  def sortDescending( x, y )
    if x.cpv_code.to_i < y.cpv_code.to_i
      return -1
    else
      return 1
    end
  end


  def deleteCPVTree
    cpvGroup = CpvGroup.find(params[:cpvGroup])
    cpvGroup.destroy
    
    if params[:referrer] == 'admin'
      redirect_to :controller => :admin, :action =>:manageCPVs
    else
      redirect_to :controller => :user, :action =>:index
    end
  end

  def save_cpv_group
    codes = params[:codes].split(",")
    category = params[:category]
    if params[:cpvGroup]
      cpvGroup = CpvGroup.find(params[:cpvGroup])
      cpvGroup.tender_cpv_classifiers.delete_all
    else
      cpvGroup = CpvGroup.new
      cpvGroup.user_id = params[:user_id]
      cpvGroup.name = category
    end
    
    codes.each do |code|      
      cpvs = TenderCpvClassifier.where( :cpv_code => code.to_i )
      cpvs.each do |cpvObject|
        cpvGroup.tender_cpv_classifiers << cpvObject
      end
    end
    cpvGroup.save

    if params[:referrer] == 'admin'
      redirect_to :controller => :admin, :action =>:manageCPVs
    else
      redirect_to :controller => :user, :action =>:index
    end
  end

  def editCPVTree
    showCPVTree()
    
    group = nil
    if params[:cpvGroup]
      group = CpvGroup.find(params[:cpvGroup]) 
    else
      #get special cpv group and fill out selected items
      #1 is all 2 is risky    
      group = CpvGroup.find(2)
    end

    group.tender_cpv_classifiers.each do |cpv|
      @checkedNodes = @checkedNodes +","+ cpv.cpv_code.to_s
    end
    @cpvGroup = group.id
    @cpvName = group.name
    @referrer = params[:referrer]
  end


  def outputTree()
    root = { :item => nil, :children => [], :parent => nil }
    csv_text = File.read("lib/data/cpv_data.csv")
    codes = CSV.parse(csv_text)
    codes.sort! {|x,y| x[0] <=> y[0] }      
	  createTree( root, codes )
    @dataId = 1
    @jsonString = '{ "data" : "00000000 : CPV Codes", 
                     "attr" : {
                        "id" : "1"
                      },
                     "state" : "open", 
                     "children" : ['
    @jsonString += printTree(root)
    @jsonString.chop!
  end

  def printTree( root )
    treeString = ""
    if root[:item]
      @dataId += 1
      codeStr = root[:item][0].to_s
      treeString +='{ "data" : "'+codeStr+' : '+ root[:item][1] +'", 
                      "attr" : {
                        "id" : "'+@dataId.to_s+'"
                      }'
      if root[:children].length > 0
        treeString += ',"children" : ['
      end
    end

    root[:children].each do |child|
      treeString += printTree( child )
    end
    if root[:children].length > 0 
      treeString.chop!
      treeString+= ']'
    end
    treeString += '},'
    return treeString
  end

  def showCPVTree
    @userID = params[:user_id]
    @checkedNodes = ""
    outputTree()
  end

  def isChild(parent, node)
    if parent[:item] == nil 
      return true
    else
      parentString = parent[:item][0]
      codeString = node[:item][0]
      digits = countZeros(parentString)
      subParent = parentString[0, parentString.length-digits]
      subCode = codeString[0, codeString.length-digits]
      return subParent == subCode
    end
  end

  def findParent( prevNode, curNode )
    if isChild( prevNode, curNode )
      return prevNode
    else
      if prevNode[:parent]
        return findParent(prevNode[:parent],curNode)
      else
        return nil
      end
    end
  end 

  def createTree( root, list )
    prev = root
    parent = root
    count = 0
    list.each do |item|
      count += 1
      
      node = { :item => item, :children => [], :parent => nil }
      
      node[:parent] = findParent(prev, node)
      if node[:parent]
        node[:parent][:children].push(node)
      else
        root[:children].push(node)
      end
      prev = node  
    end
  end


end
