class TendersController < ApplicationController
  helper_method :sort_column, :sort_direction
  def search
    @params = params
    liveDataSetID = Dataset.where(:is_live => true).first.id
    reg_num = params[:tender_registration_number]
    status = params[:tender_status]
    cpvGroupID = params[:cpvGroup]

    reg_num = "%"+reg_num+"%"
    status = "%"+status+"%"
    strDate = params[:announced_after].gsub('/','-')
    startDate = Date.strptime(strDate,'%d-%m-%Y')

    strDate = params[:announced_before].gsub('/','-')
    endDate = Date.strptime(strDate,'%d-%m-%Y')
    min = -1
    max = 99999999
    minStr = params[:min_estimate]
    maxStr = params[:max_estimate]
    if not minStr == ""
      min = minStr.to_i
    end
    if not maxStr == ""
      max = maxStr.to_i
    end
    
    translated_status =  "%%"
    if not status == "%%"
      translated_status = t(status.gsub('%',''), :locale => :ka)
    end

    resultTenders = []
    if cpvGroupID
      cpvGroup = CpvGroup.find(cpvGroupID)
    end
    
    query = "dataset_id = " + liveDataSetID.to_s +
            " AND tender_registration_number LIKE '"+reg_num+"'"+
            " AND tender_status LIKE '"+translated_status+"'"+
            " AND tender_announcement_date >= '"+startDate.to_s+"'"+
            " AND tender_announcement_date <= '"+endDate.to_s+"'"+
            " AND estimated_value >= '"+min.to_s+"'"+
            " AND estimated_value <= '"+max.to_s+"'"

    if not cpvGroupID or cpvGroup.id == 1
    else      
      cpvCategories = cpvGroup.tender_cpv_classifiers
      count = 1
      cpvCategories.each do |category|
        conjunction = " AND"
        if count > 1
          conjunction = " OR"
        end
        query = query + conjunction+" cpv_code = "+category.cpv_code
        count = count + 1
      end
    end
    resultTenders = Tender.where(query)
    @tenders = resultTenders.paginate(:page => params[:page]).order(sort_column + ' ' + sort_direction)

    @results = []
    @tenders.each do |tender|
      item = { :tender => tender, :procurer => Organization.find(tender.procurring_entity_id).name }
      @results.push(item)
    end

    @searchType = "tender" 

    if current_user
      searches = current_user.searches
      delim = '#'
      if params[:min_estimate] == ""
        params[:min_estimate] = "0"
      end
      @thisSearchString =
        params[:cpvGroup] + delim + 
        params[:tender_registration_number] + delim +
        params[:tender_status] + delim +
        params[:announced_after] + delim +
        params[:announced_before] + delim +
        params[:max_estimate] + delim +
        params[:min_estimate]
      results = Search.where( :user_id => current_user.id, :searchtype => @searchType, :search_string => @thisSearchString )
      if results.count > 0
        @searchIsSaved = true
        @savedName = results.first.name
      end
    end

  end

  def show
    @tender = Tender.find(params[:id])
    @tenderUrl = @tender.url_id
    @isWatched = false
    if current_user
      watched_tenders = current_user.watch_tenders
      watched_tenders.each do |watched|
        if watched.tender_url.to_i == @tender.url_id.to_i
          @isWatched = true
          break
        end
      end
    end
    @procurer = Organization.find(@tender.procurring_entity_id).name
    agreements = @tender.agreements
    @agreementInfo = []
    agreements.each do |agreement|
      infoItem = { :Type => "Agreement", :OrgName => nil, :OrgID => agreement.organization_id, :value => agreement.amount, :startDate => agreement.start_date, :expiryDate => agreement.expiry_date, :document => agreement.documentation_url }
      if agreement.amendment_number > 0
        infoItem[:Type] = "Amendment "+agreement.amendment_number.to_s
      end
      infoItem[:OrgName] = Organization.find(agreement.organization_id).name
      @agreementInfo.push(infoItem)
    end

    bidders = @tender.bidders
    @bidderInfo = []
    bidders.each do |bidder|
      org = Organization.find(bidder.organization_id)
      if org
        infoItem = { :id => org.id, :name => org.name, :won => false, :highBid => bidder.first_bid_amount, :lowBid => bidder.last_bid_amount, :numBids => bidder.number_of_bids}

        agreements.each do |agreement|
          if agreement.organization_id == org.id
            infoItem[:won] = true
            break
          end
        end
        @bidderInfo.push(infoItem)
      end
    end
    @bidderInfo.sort! { |a,b| (a[:lowBid] < b[:lowBid] ? -1 : 1) }
  end

  private
  def sort_column
    params[:sort] || "tender_registration_number"
  end

  def sort_direction
    params[:direction] || "asc"
  end

end
