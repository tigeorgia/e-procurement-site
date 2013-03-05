class CpvTreeController < ApplicationController
  
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
    cpvGroup = CpvGroup.find(params[:cpvGroup])
    cpvGroup.tender_cpv_classifiers.delete_all
    
    codes.each do |code|
      cpv = TenderCpvClassifier.where( :cpv_code => code.to_i ).first
      cpvGroup.tender_cpv_classifiers << cpv
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

  def showCPVTree
    if not @root
		  codes = TenderCpvClassifier.find(:all)
		  root = { :item => nil, :children => [] }
		  cpvs.sort! {|x,y| sortDescending(x,y) }

		  createTree( root, cpvs )
		  @root = root
		end
    @userID = params[:user_id]
    @checkedNodes = ""
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
    if parent[:item] == nil 
      return true
    else
      digits = countZeros(parent[:item].cpv_code)
      parentString = parent[:item].cpv_code
      subParent = parentString[0, parentString.length-digits]
      codeString = node[:item].cpv_code
      subCode = codeString[0, codeString.length-digits]
      return subParent == subCode
    end
  end

  def createTree( root, list )
    prev = root
    parent = root

    list.each do |item|
      node = { :item => item, :children => [] }
      if isChild(prev, node)
        parent = prev
      end
      if not isChild(parent, node)
        parent = root
      end
        
      parent[:children].push(node)
      prev = node  
    end
  end

  def printTree( root )
    if root[:item]
      puts root[:item].description
    end

    root[:children].each do |child|
      printTree( child )
    end
  end


end
