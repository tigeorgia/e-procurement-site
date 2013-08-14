# encoding: utf-8 
module AggregateHelper
  require "graph_helper"
  class TenderTypeStat
   def initialize(name)
      @name = name
      @count = 0
      @successCount = 0
      @value = 0
      @averageBidDuration = 0
      @averageWarningPeriod = 0
      @averageBidders = 0
      @averageBids = 0
      @totalBidders = 0
      @totalBids = 0
      @agreements = 0
      @illegalTenders = []
      @biddingTimes = {}
      @biddingWarnings = {}
    end
    def addStats(tender)
      @count = @count + 1
      @value = @value + tender.estimated_value
     
      biddingPeriod = (tender.bid_end_date - tender.bid_start_date).to_i
      warningPeriod = (tender.bid_start_date - tender.tender_announcement_date).to_i
      
      if biddingPeriod < 2 or warningPeriod < 1
        @illegalTenders.push(tender)
      end

      if @biddingTimes[biddingPeriod] 
        @biddingTimes[biddingPeriod] += 1
      else
        @biddingTimes[biddingPeriod] = 1
      end

      if @biddingWarnings[warningPeriod]
        @biddingWarnings[warningPeriod] += 1
      else
        @biddingWarnings[warningPeriod] = 1
      end

      @averageBidDuration += biddingPeriod.to_f
      @averageWarningPeriod += warningPeriod.to_f

      if tender.num_bidders > 0
       @successCount = @successCount + 1
       @totalBidders += tender.num_bidders.to_f
       @totalBids += tender.num_bids.to_f
      end
    end
    def calcAverages()
      if @averageBidDuration > 0
        @averageBidDuration = @averageBidDuration.to_f / @count
      end
      if @averageWarningPeriod > 0
        @averageWarningPeriod = @averageWarningPeriod.to_f / @count
      end
      if @averageBidders > 0
        @averageBidders = @totalBidders.to_f / @successCount
      end
      if @averageBids > 0
        @averageBids = @totalBids.to_f / @successCount
      end
    end
    
    def getName
      return @name
    end

    def getIllegalTenders
      return @illegalTenders
    end

    def getCount
      return @count
    end

    def getAgreementCount
      return @agreements
    end

    def getBiddingTimes
      return @biddingTimes
    end

    def getBiddingWarnings
      return @biddingWarnings
    end

    def getValue
      return @value
    end

    def getAverageBidDuration
      return @averageBidDuration
    end

    def getAverageWarningPeriod
      return @averageWarningPeriod
    end

    def getAverageBids
      return @averageBids
    end

    def getAverageBidders
      return @averageBidders
    end

    def getTotalBidders
      return @totalBidders
    end

    def getTotalBids
      return @totalBids
    end

    def getNumTendersWithBidders
      return @successCount.to_f/@count.to_f
    end

    def getSuccessCount
      return @successCount
    end
  end   

  def self.getYearRange
    years = []
    firstTender = Tender.limit(1).order("tender_announcement_date ASC")[0]
    firstYear = firstTender.tender_announcement_date.year
    lastYear = DateTime.now.year
    curYear = firstYear
    while curYear <= lastYear
      years.push( curYear )
      curYear += 1
    end
    return years
  end

  def self.createYearStat()
    stat = {
      :total => {:tenderStats => TenderTypeStat.new("total"), 
                 :bid_data => {}, 
                 :cpv_agreements => {}, 
                 :bidDurationVsBidders => []
                },
      :simple_electronic => {:tenderStats => TenderTypeStat.new('Simple Electronic Tender'),
                             :bid_data => {}, 
                             :cpv_agreements => {}, 
                             :bidDurationVsBidders => []
                            },
      :electronic => {:tenderStats => TenderTypeStat.new('Electronic Tender'),
                      :bid_data => {}, 
                      :cpv_agreements => {}, 
                      :bidDurationVsBidders => []
                      }
    }
    return stat
  end
    
  def self.calcBidStats( bidData, tender )
    duration = (tender.bid_end_date - tender.tender_announcement_date).to_i

    if duration > 0 and tender.num_bidders > 0
      total = bidData[duration]
      if not total
        bidData[duration] = [tender.num_bidders, 1]
      else
        total[0] = total[0] + tender.num_bidders
        total[1] = total[1] + 1
        bidData[duration] = total
      end
    end 
  end

  def self.addCpvStats( stats, tender )
    if tender.contract_value and tender.contract_value > 0
      cpvAgreements = stats[:cpv_agreements]
      cpvCodes = []
      if not tender.sub_codes
        if tender.cpv_code
          cpvCodes.push(tender.cpv_code)
        end
      else
        cpvCodes = tender.sub_codes.split("#")
      end
      
      if cpvCodes[-1].to_i < 1000
        cpvCodes.pop
      end
      codeCount = cpvCodes.length
      cpvCodes.each do |cpvCode|
        if cpvCode.to_i < 1000
          puts "wtf: "+tender.id.to_s
          puts "code: "+cpvCode.to_s
        end
        value = tender.contract_value.to_f/codeCount
        if not cpvAgreements[cpvCode]
          cpvAgreements[cpvCode] = value
        else
          old = cpvAgreements[cpvCode]
          old += value
          cpvAgreements[cpvCode] = old
        end
      end
    end
  end

  def self.calcAggergateAverages( stats )
    stats.each do |key, stat|
      stat[:tenderStats].calcAverages()
      bidDurationVsBidders = stat[:bidDurationVsBidders]
      stat[:bid_data].each do |key, bidData|  
        average = bidData[0].to_f / bidData[1].to_f
        dataPoint = [key,average,bidData[1].to_f]
        #if this average is made up of atleast %1 of all tenders
        if bidData[1] > stat[:tenderStats].getSuccessCount() / 100
          bidDurationVsBidders.push( dataPoint )
        end
      end
    end
  end

  def self.addStats( stats, tender )
    stats[:tenderStats].addStats(tender)
    self.calcBidStats(stats[:bid_data], tender)
    self.addCpvStats(stats, tender)
  end

  def self.generateAndStoreAggregateData
    stats = {}
    #placeholder for 'all' group 
    stats[0] = self.createYearStat()

    years = self.getYearRange()
    years.each do |year|
      stats[year] = self.createYearStat()
    end   
    count = 0
    Tender.find_each do |tender|   
      if count%1000 == 0
        puts "Tenders: "+ count.to_s
      end
      count += 1
      year = tender.tender_announcement_date.year
      yearStats = stats[year]
      if tender.tender_type.strip() == "ელექტრონული ტენდერი"
        self.addStats(yearStats[:electronic], tender)
      elsif tender.tender_type.strip() == "გამარტივებული ელექტრონული ტენდერი"
        self.addStats(yearStats[:simple_electronic], tender)
      end
      self.addStats(yearStats[:total], tender)       
    end

    puts "calc averages"
    #now we have all stats calc the averages
    stats.each do |key, stat|
      self.calcAggergateAverages(stat)
    end

    puts "storing into db"
    #alright we have finished gathering info time to store this into the db
    count = 0
    puts "removing old stats"
    AggregateStatistic.all.each do |statistic|
      statistic.destroy
    end
    AggregateStatisticType.all.each do |type|
      type.destroy
    end
    puts "creating new stats"
    stats.each do | year, data |
      statistic = AggregateStatistic.new
      statistic.id = year
      statistic.year = year
      statistic.save
      puts "prcoessing: "+year.to_s
      #now create tender stats for the tender types
      types = [ [:total,"total"],[:simple_electronic,"simple electronic"], [:electronic, "electronic"] ]
      types.each do | pair |       
        dbType = AggregateStatisticType.new
        dbType.aggregate_statistic_id = statistic.id
        dbType.name = pair[1]
        dbType.save

        type = pair[0]
        puts "processing: "+ pair[1]
        
        tender_data = data[type][:tenderStats]
        dbTenderStats = AggregateTenderStatistic.new
        dbTenderStats.aggregate_statistic_type_id = dbType.id
        dbTenderStats.count = tender_data.getCount
        dbTenderStats.success_count = tender_data.getSuccessCount
        dbTenderStats.total_value = tender_data.getValue
        dbTenderStats.average_bid_duration = tender_data.getAverageBidDuration
        dbTenderStats.average_warning_period = tender_data.getAverageWarningPeriod
        dbTenderStats.total_bidders = tender_data.getTotalBidders
        dbTenderStats.total_bids = tender_data.getTotalBids
        dbTenderStats.agreements = tender_data.getAgreementCount
        dbTenderStats.save
        
        #create cpv aggregate stats
        cpv_data = data[type][:cpv_agreements]
        cpv_data.each do | code, value |
          cpvStat = AggregateCpvStatistic.new
          cpvStat.aggregate_statistic_type_id = dbType.id
          cpvStat.cpv_code = code
          cpvStat.value = value
          cpvStat.save
        end

        #store bidding stats
        bidDurationData = data[type][:bidDurationVsBidders]
        bidDurationData.each do |datapoint|
          bidStat = AggregateBidStatistic.new
          bidStat.aggregate_statistic_type_id = dbType.id
          bidStat.duration = datapoint[0]
          bidStat.average_bids = datapoint[1]
          bidStat.tender_count = datapoint[2]
          bidStat.save
        end#bids
        if dbType.name == "total" 
          self.createCPVTree(dbType, statistic)
        end
      end#types        
    end#years

    self.calculateAnnualCpvRevenues
  end


  def self.calculateAnnualCpvRevenues
    #for each CPV code calculate the revenue generated for each company and store these entries in the database
    #this way when aggregate data is requested instead of running this expensive process everytime we can just look up the pre-calculated entries in the db.
    AggregateCpvRevenue.delete_all
    ProcurerCpvRevenue.delete_all
    Tender.find_each do |tender|
      if tender.contract_value and tender.contract_value > 0
        year = tender.tender_announcement_date.year.to_i
        aggregateYearSet = AggregateStatistic.where(:year => year).first
        if aggregateYearSet
          cpv_codes = []
          if not tender.sub_codes
            puts "No sub_code: #{tender.id}"
            if tender.cpv_code
              cpv_codes.push(tender.cpv_code)
            end
          else
            cpv_codes = tender.sub_codes.split("#")
          end
          numCodes = cpv_codes.size
          valuePerCode = tender.contract_value.to_f/numCodes
          company = Organization.where(:id => tender.winning_org_id).first
          procurer = Organization.where(:id => tender.procurring_entity_id).first
          cpv_codes.each do |code|
            if company
              aggregateData = AggregateCpvRevenue.where(:aggregate_statistic_id => aggregateYearSet.id, :cpv_code => code, :organization_id => company.id).first
              if not aggregateData
                aggregateData = AggregateCpvRevenue.new
                aggregateData.organization_id = company.id
                aggregateData.cpv_code = code
                aggregateData.total_value = valuePerCode
                aggregateData.aggregate_statistic_id = aggregateYearSet.id
              else
                aggregateData.total_value = aggregateData.total_value + valuePerCode
              end
              aggregateData.save
            end
        
            if procurer
              aggregateData = ProcurerCpvRevenue.where(:aggregate_statistic_id => aggregateYearSet.id, :cpv_code => code, :organization_id => procurer.id).first
              if not aggregateData
                aggregateData = ProcurerCpvRevenue.new
                aggregateData.organization_id = procurer.id
                aggregateData.cpv_code = code
                aggregateData.total_value = valuePerCode
                aggregateData.aggregate_statistic_id = aggregateYearSet.id
              else
                aggregateData.total_value = aggregateData.total_value + valuePerCode
              end
              aggregateData.save
            end
          end

          #add to all cpv stats
          code = "all"
          if company
            aggregateData = AggregateCpvRevenue.where(:aggregate_statistic_id => aggregateYearSet.id, :cpv_code => code, :organization_id => company.id).first
            if not aggregateData
              aggregateData = AggregateCpvRevenue.new
              aggregateData.organization_id = company.id
              aggregateData.cpv_code = code
              aggregateData.total_value = tender.contract_value
              aggregateData.aggregate_statistic_id = aggregateYearSet.id
            else
              aggregateData.total_value = aggregateData.total_value + tender.contract_value
            end
            aggregateData.save
          end
          if procurer
            aggregateData = ProcurerCpvRevenue.where(:aggregate_statistic_id => aggregateYearSet.id, :cpv_code => code, :organization_id => procurer.id).first
            if not aggregateData
              aggregateData = ProcurerCpvRevenue.new
              aggregateData.organization_id = procurer.id
              aggregateData.cpv_code = code
              aggregateData.total_value = tender.contract_value
              aggregateData.aggregate_statistic_id = aggregateYearSet.id
            else
              aggregateData.total_value = aggregateData.total_value + tender.contract_value
            end
            aggregateData.save
          end
        end
      end
    end
  end


  #only for testing real function added above
  #be careful doesn't delete old data
  def self.addAllCPVStats
    Tender.find_each do |tender|
      if tender.contract_value and tender.contract_value > 0
        puts tender.id
        year = tender.tender_announcement_date.year.to_i
        aggregateYearSet = AggregateStatistic.where(:year => year).first
        if aggregateYearSet
          company = Organization.where(:id => tender.winning_org_id).first
          procurer = Organization.where(:id => tender.procurring_entity_id).first
          #add to all cpv stat
          code = "all"
          if company
            aggregateData = AggregateCpvRevenue.where(:aggregate_statistic_id => aggregateYearSet.id, :cpv_code => code, :organization_id => company.id).first
            if not aggregateData
              aggregateData = AggregateCpvRevenue.new
              aggregateData.organization_id = company.id
              aggregateData.cpv_code = code
              aggregateData.total_value = tender.contract_value
              aggregateData.aggregate_statistic_id = aggregateYearSet.id
            else
              aggregateData.total_value = aggregateData.total_value + tender.contract_value
            end
            aggregateData.save
          end
          if procurer
            aggregateData = ProcurerCpvRevenue.where(:aggregate_statistic_id => aggregateYearSet.id, :cpv_code => code, :organization_id => procurer.id).first
            if not aggregateData
              aggregateData = ProcurerCpvRevenue.new
              aggregateData.organization_id = procurer.id
              aggregateData.cpv_code = code
              aggregateData.total_value = tender.contract_value
              aggregateData.aggregate_statistic_id = aggregateYearSet.id
            else
              aggregateData.total_value = aggregateData.total_value + tender.contract_value
            end
            aggregateData.save
          end
        end
      end
    end
  end

  def self.regenCPVTree
    AggregateStatistic.all.each do |statistic|
       dbtype = AggregateStatisticType.where(:aggregate_statistic_id => statistic.id, :name => "total").first
       if dbtype
        self.createCPVTree(dbtype, statistic)
       end
    end
  end

  def self.createCPVTree(dbType, statisticYear)
    cpvTree = {}
    cpvTreeGEO = {}
    cpvData = AggregateCpvStatistic.where(:aggregate_statistic_type_id => dbType.id)
    cpvData.each do |cpv|
      #get cpv name
      code = cpv.cpv_code.to_s
      #hax to convert int to string with 0s at the front
      while code.length < 8
        code = "0"+code
      end
      classifier = TenderCpvClassifier.where(:cpv_code => code).first
      if classifier
        name = classifier.description_english
        if not name
          name = "Not Specified"
        end
        cpvTree[code] = { :name => name, :code => code, :value => cpv.value.to_i, :children => [] }

        #now geo
        geoName = classifier.description
        if not geoName
          geoName = name
        end
        cpvTreeGEO[code] = { :name => geoName, :code => code, :value => cpv.value.to_i, :children => [] }
      else
        puts "cant find classifier: "+code
      end
    end
    cpvString = GraphHelper.createTreeGraphStringFromAgreements(cpvTree, "en")
    cpvStringGeo = GraphHelper.createTreeGraphStringFromAgreements(cpvTreeGEO, "ka")
    statisticYear.cpvString = cpvString
    statisticYear.cpvStringGEO = cpvStringGeo
    statisticYear.save
  end
end

