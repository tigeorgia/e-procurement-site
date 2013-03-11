# encoding: utf-8 
class OrganizationsController < ApplicationController
  helper_method :sort_column, :sort_direction
  def search
    @params = params
    name = params[:organization][:name]
    code = params[:organization][:code]
    org_type = params[:org_type]
    name = "%"+name+"%"
    code = "%"+code+"%"
    
    foreignOnly = params[:isForeign][:foreign]

    orgString = ""
    if not org_type == ""
      orgString = " AND org_type = '"+org_type+"'"
    end
    conditions = "is_bidder = true AND name LIKE '"+name+"' AND code LIKE '"+code +"'"+ orgString
    if foreignOnly == '1'
      conditions += " AND country NOT LIKE 'საქართველო'"
    end  

    results = Organization.where(conditions)
    @numResults = results.count
    @organizations = results.paginate(:page => params[:page]).order(sort_column + ' ' + sort_direction)
  end

  def search_procurer
    @params = params
    name = params[:organization][:name]
    code = params[:organization][:code]
    org_type = params[:org_type]
    name = "%"+name+"%"
    code = "%"+code+"%"
    #dirty hack remove this scrape side
    if org_type == "50% მეტი სახ წილ საწარმო"
      org_type = "50% მეტი სახ. წილ. საწარმო"
    end
    orgString = ""
    if not org_type == ""
      orgString = " AND org_type ='"+org_type+"'"
    end
    conditions = "is_procurer = true AND name LIKE '"+name+"' AND code LIKE '"+code+"'"+ orgString
    results = Organization.where(conditions)
    @numResults = results.count
    @organizations = results.paginate( :page => params[:page]).order(sort_column + ' ' + sort_direction)
  end

  def show_procurer
    id = params[:id]
    @organization = Organization.find(id)
    tenders = Tender.find_all_by_procurring_entity_id(id)
    @numTenders = tenders.count
    @totalEstimate = 0
    @actualCost = 0
    totalBids = 0
    totalBidders = 0
    @numAgreements = 0

    @tendersOffered = []
    tenders.each do |tender|
      cpvDescription = TenderCpvClassifier.where(:cpv_code => tender.cpv_code).first.description_english
      tender[:cpvDescription] = cpvDescription
      @tendersOffered.push(tender)
    end

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
    @topFiveCpvs = []
    tendersPerCpv = {}
    allBids.each do |bid|
      tender = Tender.find(bid.tender_id)
      allTenders.push(tender)
      if tendersPerCpv[tender.cpv_code]
        tendersPerCpv[tender.cpv_code] += 1
      else
        tendersPerCpv[tender.cpv_code] = 1
      end
    end
    
    tendersPerCpv = tendersPerCpv.sort { |a,b| b[1] <=> a[1]}
    @topFiveCpvs = []
    count = 0
    tendersPerCpv.each do |key, value|
      count = count + 1
      if count > 5
        break
      end
      @topFiveCpvs.push( [key,value] )
    end 
    

    tendersWon = {}
    #find all tenders we won
    if allAgreements
      allAgreements.each do |agreement|
        agreementTender = tendersWon[agreement.tender_id]
        if not agreementTender
          tendersWon[agreement.tender_id] = [agreement,Tender.find(agreement.tender_id)]
        elsif agreementTender[0].amendment_number < agreement.amendment_number
          tendersWon[agreement.tender_id] = [agreement, agreementTender[1]]
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
    @totalValueOfAllContracts = 0
    @totalEstimatedValueOfContractsWon = 0
    @averageNumBiddersOnContractsWon = 0
    procuringEntities = {}
    tendersWon.each do |key, tender|
      @totalValueOfAllContracts += tender[0].amount
      @totalEstimatedValueOfContractsWon += tender[1].estimated_value
      @averageNumBiddersOnContractsWon += tender[1].bidders.count
      procuringID = tender[1].procurring_entity_id
      if procuringEntities[procuringID]
        procuringEntities[procuringID] += 1
      else
        procuringEntities[procuringID] = 1
      end
    end

    procuringEntities = procuringEntities.sort { |a,b| b[1] <=> a[1]}
    @topTenProcuringEntities = []
    count = 0

    procuringEntities.each do |key, value|
      count = count + 1
      if count > 10
        break
      end
      @topTenProcuringEntities.push( [key,value] )
    end
    if @numTendersWon != 0
      @averageNumBiddersOnContractsWon = @averageNumBiddersOnContractsWon / @numTendersWon
    end

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
