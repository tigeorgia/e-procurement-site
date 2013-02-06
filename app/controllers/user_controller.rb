class UserController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    watched_tenders = current_user.watch_tenders
    liveDataSetID = Dataset.where(:is_live => true).first.id
    @tenders = []
    watched_tenders.each do |watch_tender|
      url = watch_tender.tender_url
      tender = Tender.where(:url_id => url, :dataset_id => liveDataSetID).first
      @tenders.push(tender)
    end

    @savedSearches = current_user.searches
    @cpvGroups = current_user.cpvGroups
    @userID = current_user.id
  end

  def save_search
    newSearch = Search.new
    newSearch.user_id = current_user.id
    newSearch.searchtype = params[:searchtype]
    newSearch.search_string = params[:search_string]
    newSearch.name = params[:name]
    @savedName = params[:name]
    newSearch.save
    @thisSearchString = params[:search_string]
    @searchType = params[:searchtype]
  end

  def remove_search
    searchList = Search.where( :user_id => current_user.id, :searchtype => params[:searchtype], :name => params[:name], :search_string => params[:search_string] )
    searchList.each do |search|
      search.destroy
    end
    @thisSearchString = params[:search_string]
    @searchType = params[:searchtype]
  end

  def subscribe_tender
    watch_item = WatchTender.new
    watch_item.tender_url = params[:tender_url]
    watch_item.user_id = params[:user_id]
    watch_item.save
  end

  def unsubscribe_tender
    subscribed = WatchTender.where( :tender_url => params[:tender_url], :user_id => params[:user_id] )
    subscribed.each do |watch_tender|
      watch_tender.destroy
    end
  end

  def rebuild_search
    if params[:searchtype] == "tender"
      fields = params[:searchString].split("#")
      redirect_to :controller => "tenders", :action => "search",
      :cpvGroup => fields[0],
      :tender_registration_number => fields[1],
      :tender_status => fields[2],
      :announced_after => fields[3],
      :announced_before => fields[4],
      :max_estimate => fields[5],
      :min_estimate => fields[6]
    end
  end

  def newCPVGroup
    @userID = params[:user_id]
  end
  
  def create_group
    user = User.find(params[:user_id])
    group = CpvGroup.new
    group.user_id = user.id
    group.name = params[:name]
    group.save
  end

  def save_cpv_group
    codes = params[:codes].split(",")
    category = params[:category]
    cpvGroup = CpvGroup.new
    cpvGroup.user_id = params[:user_id]
    cpvGroup.name = category
    
    codes.each do |code|
      cpv = TenderCpvClassifier.where( :cpv_code => code.to_i ).first
      cpvGroup.tender_cpv_classifiers << cpv
    end
    cpvGroup.save
    if cpvGroup.user_id == current_user.id
      redirect_to :action => :index
    else
      redirect_to :controller => :admin, :action =>:manageCPVs
    end
  end

end
