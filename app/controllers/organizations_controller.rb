# encoding: utf-8 
class OrganizationsController < ApplicationController
  helper_method :sort_column, :sort_direction
  def search
    @params = params
    liveDataSetID = Dataset.where(:is_live => true).first.id
    name = params[:organization][:name]
    code = params[:organization][:code]
    org_type = params[:organization][:org_type]
    name = "%"+name+"%"
    code = "%"+code+"%"
    org_type = "%"+org_type+"%"
    
    foreignOnly = params[:isForeign][:foreign]

    conditions = ["dataset_id = ? AND is_bidder=true AND name LIKE ? AND code LIKE ? AND org_type LIKE ?",liveDataSetID, name, code, org_type]
    if foreignOnly == '1'
      conditions = ["dataset_id = ? AND is_bidder=true AND name LIKE ? AND code LIKE ? AND org_type LIKE ? AND country NOT LIKE ?",liveDataSetID, name, code, org_type, "საქართველო"]
    end  

    @organizations = Organization.paginate( :page => params[:page], :conditions => conditions	).order(sort_column + ' ' + sort_direction)
  end

  def search_procurer
    @params = params
    liveDataSetID = Dataset.where(:is_live => true).first.id
    name = params[:organization][:name]
    code = params[:organization][:code]
    org_type = params[:organization][:org_type]
    name = "%"+name+"%"
    code = "%"+code+"%"
    org_type = "%"+org_type+"%"
    @organizations = Organization.paginate( :page => params[:page], :conditions => ["dataset_id = ? AND is_procurer=true AND name LIKE ? AND code LIKE ? AND org_type LIKE ?",liveDataSetID, name, code, org_type]	).order(sort_column + ' ' + sort_direction)
  end

  def show_procurer
    id = params[:id]
    @organization = Organization.find(id)
    @tendersOffered = Tender.find_all_by_procurring_entity_id(id)
    @numTenders = @tendersOffered.count
    @totalEstimate = 0
    @actualCost = 0
    totalBids = 0
    totalBidders = 0
    @numAgreements = 0

    #lets get some aggregate tender stats
    @tendersOffered.each do |tender|    
      agreements = Agreement.find_all_by_tender_id(tender.id)
      #get last agreement
      lastAgreement = nil
      agreements.each do |agreement|
        if not lastAgreement or lastAgreement.amendment_number < agreement.amendment_number
          lastAgreement = agreement
        end
      end
      if lastAgreement
        @actualCost += lastAgreement.amount
        @numAgreements += 1
        @totalEstimate += tender.estimated_value
      else
        puts tender.id
      end

      #now look at bid stats
      bidders = Bidder.find_all_by_tender_id(tender.id)
      bidders.each do |bidder|
        totalBids += bidder.number_of_bids
      end
      totalBidders += bidders.count
    end

    #time for tasty averages
    @averageBids = totalBids.to_f/@numTenders
    @averageBidders = totalBidders.to_f/@numTenders
    @numNoAgreements = @numTenders - @numAgreements
    costString = "N/A"
    if @totalEstimate > 0
      costString = "%.1f" % ((1-@actualCost/@totalEstimate)*100)
    end
    @costVsEstimateSaving = costString
  end
                          

  def show
    id = params[:id]
    @organization = Organization.find(id)
 
    allAgreements = Agreement.find_all_by_organization_id(id)
    allBids = Bidder.find_all_by_organization_id(id)
    allTenders = []
    allBids.each do |bid|
      allTenders.push( Tender.find(bid.tender_id) )
    end

    tendersWon = {}
    #find all tenders we won
    if allAgreements
      allAgreements.each do |agreement|
        tender = tendersWon[agreement.tender_id]
        if not tender
          tendersWon[agreement.tender_id] = Tender.find(agreement.tender_id)
        end
      end
    end

    #find all competitors
    @competitors = []
    org_competitors = Competitor.where("organization_id = "+id)
    org_competitors.each do | competitor |
      info = []
      info.push(Organization.find(competitor.rival_org_id))
      info.push(competitor.num_tenders)
      @competitors.push( info )
    end

    @numTenders = allTenders.count
    @numTendersWon = tendersWon.size
    @WLR = @numTendersWon.to_f()/@numTenders.to_f()
    
    @tenderInfo = []
    #create a hash with tasty info
    allTenders.each do |tender|
      tenderDuration = (tender.bid_end_date - tender.bid_start_date).to_i
      infoItem = { :id => tender.id, :tenderCode => tender.tender_registration_number, :numBidders => tender.bidders.count, :bidDuration => tenderDuration, :highest_bid => nil, :lowest_bid => nil, :numBids => nil, :start_amount => tender.estimated_value, :won => false, :procurerName => nil, :procurerID => tender.procurring_entity_id, :tenderAnnouncementDate => tender.tender_announcement_date}
      infoItem[:procurerName] = Organization.find(tender.procurring_entity_id).name
      if tendersWon[tender.id]
        infoItem[:won] = true
      end

      allBids.each do |bid|
        if bid.tender_id == tender.id
          infoItem[:highest_bid] = bid.first_bid_amount
          infoItem[:lowest_bid] = bid.last_bid_amount
          infoItem[:numBids] = bid.number_of_bids
          break
        end
      end
      @tenderInfo.push(infoItem)
    end
    @tenderInfo.sort! { |a,b| (a[:won] ? -1 : 1) }
  end

  private

  def sort_column
    params[:sort] || "name"
  end

  def sort_direction
    params[:direction] || "asc"
  end

end
