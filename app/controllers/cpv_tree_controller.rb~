class CpvTreeController < ApplicationController
before_filter :authenticate_user!

  include ApplicationHelper
  include GraphHelper
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
    
    if params[:isGlobal]
      redirect_to :controller => :admin, :action =>:manageCPVs
    else
      redirect_to :controller => :user, :action =>:index
    end
  end

  def save_cpv_group
    codes = params[:codes].split(",")
    category = params[:category]
    isGlobal = params[:isGlobal]
    if (isGlobal and current_user.role == 'admin') or (not isGlobal)
      if params[:cpvGroup]
        cpvGroup = CpvGroup.find(params[:cpvGroup])
        cpvGroup.tender_cpv_classifiers.delete_all
      else
        cpvGroup = CpvGroup.new       
        if isGlobal
          cpvGroup.user_id = 2
        else
          cpvGroup.user_id = current_user.id
        end
        cpvGroup.name = category
      end
      
      codes.each do |code|      
        cpvs = TenderCpvClassifier.where( :cpv_code => code.to_i )
        cpvs.each do |cpvObject|
          cpvGroup.tender_cpv_classifiers << cpvObject
        end
      end
      cpvGroup.save
    end

    if params[:isGlobal]
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
  end


  def outputTree()
    root = { :name => "CPV Codes", :code => "00000000", :children => [] }
    csv_text = File.read("lib/data/cpv_data.csv")
    codes = CSV.parse(csv_text)
    nodes = []
    codes.each do |code|
      nodes.push({ :name => code[1], :code => code[0], :children => [] })
    end
    nodes.push({ :name => "Not Specified", :code => "99999999", :children => []})  
	  createTree( root, nodes )
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

    @dataId += 1
    if not root[:code] == "00000000"
      codeStr = root[:code]
      treeString +='{ "data" : "'+codeStr+' : '+ root[:name] +'", 
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
    @isGlobal = params[:isGlobal]
    @checkedNodes = ""
    #outputTree()
  end

end
