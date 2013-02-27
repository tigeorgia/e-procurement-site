class TendersController < ApplicationController
  require "query_helpers" 
  helper_method :sort_column, :sort_direction

  def performSearch( data )
    query = QueryHelper.buildTenderSearchQuery(data)
    result = Tender.where(query)
    return result
  end

  def buildQueryData( data )
    liveDataSetID = Dataset.where(:is_live => true).first.id
    reg_num = data[:tender_registration_number]
    status = data[:tender_status]
    cpvGroupID = data[:cpvGroup]

    
    reg_num = "%"+reg_num.gsub('%','')+"%"
    status = "%"+status.gsub('%','')+"%"
    strDate = data[:announced_after].gsub('/','-')
    startDate = Date.strptime(strDate,'%Y-%m-%d')


    strDate = data[:announced_before].gsub('/','-')
    endDate = Date.strptime(strDate,'%Y-%m-%d')

    minVal = data[:min_estimate]
    maxVal = data[:max_estimate]

    minBids = data[:min_num_bids]
    maxBids = data[:max_num_bids]
    
    minBidders = data[:min_num_bidders]
    maxBidders = data[:max_num_bidders]

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
    status = status.gsub('%','')
    if not status == ""
      translated_status = t(status, :locale => :ka)
    end

    resultTenders = []
    if cpvGroupID
      cpvGroup = CpvGroup.find(cpvGroupID)
    end


    queryData = {
                 :cpvGroupID => cpvGroupID.to_s,
                 :datasetID => liveDataSetID.to_s,
                 :tender_registration_number => reg_num.to_s,
                 :tender_status => translated_status,
                 :announced_after => startDate.to_s,
                 :announced_before => endDate.to_s,
                 :min_estimate => minVal.to_s,
                 :max_estimate => maxVal.to_s,
                 :min_num_bids => minBids,
                 :max_num_bids => maxBids,
                 :min_num_bidders => minBidders,
                 :max_num_bidders => maxBidders,
            }
    return queryData
  end

  def generateViewData( tenders, queryData )
    @params = params
    @numResults = tenders.count
    @tenders = tenders.paginate(:page => params[:page]).order(sort_column + ' ' + sort_direction)

    @results = []
    @tenders.each do |tender|
      item = { :tender => tender, :procurer => Organization.find(tender.procurring_entity_id).name }
      @results.push(item)
    end

    @searchType = "tender" 

    if current_user
      searches = current_user.searches
      delim = '#'
      @thisSearchString = ""
      queryData.each do |key,field|
        @thisSearchString += field + "#"
      end
        
      results = Search.where( :user_id => current_user.id, :searchtype => @searchType, :search_string => @thisSearchString )
      if results.count > 0
        @searchIsSaved = true
        @savedName = results.first.name
      end
    end
  end

  def search
    data = buildQueryData( params )
    resultTenders = performSearch( data )
    generateViewData( resultTenders, data )
  end

  def search_via_saved
    search = Search.find(params[:search_id])
    searchParams = QueryHelper.buildSearchParamsFromString(search.search_string)
    data = buildQueryData( searchParams )
    resultTenders = performSearch( data )
    generateViewData( resultTenders, data )
    @search = search
    render "search"
    @search.last_viewed = DateTime.now
    @search.has_updated = false
    @search.save
  end

  def show
    @tender = Tender.find(params[:id])
    @cpv = TenderCpvClassifier.where(:cpv_code => @tender.cpv_code).first
    @tenderUrl = @tender.url_id
    @isWatched = false
    @highlights = ""
    if params[:highlights]
     @highlights = params[:highlights].split("#")
    end
    if current_user
      watched_tenders = current_user.watch_tenders
      watched_tenders.each do |watched|
        if watched.tender_url.to_i == @tender.url_id.to_i
          @isWatched = true
          #reset the update flag to false since this tender has now been viewed
          watched.has_updated = false
          watched.save
          break
        end
      end
    end


    @risks = []
    flags = TenderCorruptionFlag.where(:tender_id => @tender.id)
    @totalRisk = 0
    flags.each do |flag|
      if not flag.corruption_indicator_id == 100
        indicator = CorruptionIndicator.find( flag.corruption_indicator_id )
        @totalRisk = @totalRisk + (indicator.weight * flag.value)
        @risks.push(indicator)
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
    params[:sort] || "updated_at"
  end

  def sort_direction
    params[:direction] || "desc"
  end
end
