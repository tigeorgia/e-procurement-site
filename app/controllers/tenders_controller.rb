class TendersController < ApplicationController
  helper_method :sort_column, :sort_direction, :buildTenderSearchQuery
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

    minVal = params[:min_estimate]
    maxVal = params[:max_estimate]

    minBids = params[:min_num_bids]
    maxBids = params[:max_num_bids]
    
    minBidders = params[:min_num_bidders]
    maxBidders = params[:max_num_bidders]

    if minVal == ""
      minVal = "-1"
    end
    if maxVal == ""
      maxVal = "99999999"
    end
    if minBids == ""
      minBids = "-1"
    end
    if maxBids == ""
      maxBids = "99999999"
    end
    if minBidders == ""
      minBidders = "-1"
    end
    if maxBidders == ""
      maxBidders = "99999999"
    end    
     
    translated_status =  "%%"
    if not status == "%%"
      translated_status = t(status.gsub('%',''), :locale => :ka)
    end

    resultTenders = []
    if cpvGroupID
      cpvGroup = CpvGroup.find(cpvGroupID)
    end

    queryData = {:cpvGroupID => cpvGroupID.to_s,
                 :datasetID => liveDataSetID.to_s,
                 :registration_number => reg_num,
                 :tender_status => translated_status,
                 :announced_after => startDate.to_s,
                 :announced_before => endDate.to_s,
                 :minVal => minVal.to_s,
                 :maxVal => maxVal.to_s,
                 :min_bids => minBids,
                 :max_bids => maxBids,
                 :min_bidders => minBidders,
                 :max_bidders => maxBidders,
            }

    query = buildTenderSearchQuery(queryData)
    resultTenders = Tender.where(query)
    @numResults = resultTenders.count
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
        params[:min_estimate] + delim +
        params[:min_num_bids] + delim +
        params[:max_num_bids] + delim +
        params[:min_num_bidders] + delim +
        params[:max_num_bidders]
      results = Search.where( :user_id => current_user.id, :searchtype => @searchType, :search_string => @thisSearchString )
      if results.count > 0
        @searchIsSaved = true
        @savedName = results.first.name
      end
    end

  end

  def show
    @tender = Tender.find(params[:id])
    @cpv = TenderCpvClassifier.where(:cpv_code => @tender.cpv_code).first
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


    @risks = []
    flags = TenderCorruptionFlag.where(:tender_id => @tender.id)
    @totalRisk = 0
    flags.each do |flag|
      indicator = CorruptionIndicator.find( flag.corruption_indicator_id )
      @totalRisk = @totalRisk + (indicator.weight * flag.value)
      @risks.push(indicator)
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

  def buildTenderSearchQuery(params)
    #all params should already be in string format
    query = "dataset_id = '" +params[:datasetID]+"'"+
        " AND tender_registration_number LIKE '"+params[:registration_number]+"'"+
        " AND tender_status LIKE '"+params[:tender_status]+"'"+
        " AND tender_announcement_date >= '"+params[:announced_after]+"'"+
        " AND tender_announcement_date <= '"+params[:announced_before]+"'"+
        " AND estimated_value >= '"+params[:minVal]+"'"+
        " AND estimated_value <= '"+params[:maxVal]+"'"+
        " AND num_bids >= '"+params[:min_bids]+"'"+
        " AND num_bids <= '"+params[:max_bids]+"'"+
        " AND num_bidders >= '"+params[:min_bidders]+"'"+
        " AND num_bidders <= '"+params[:max_bidders]+"'"

    cpvGroup = CpvGroup.where(:id => params[:cpvGroupID]).first
    if not cpvGroup or cpvGroup.id == 1
    else      
      cpvCategories = cpvGroup.tender_cpv_classifiers
      count = 1
      cpvCategories.each do |category|
        conjunction = " AND ("
        if count > 1
          conjunction = " OR"
        end
        query = query + conjunction+" cpv_code = "+category.cpv_code
        count = count + 1
      end
      query = query + " )"
    end
    return query
  end

end
