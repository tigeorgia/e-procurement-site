#!/bin/env ruby
# encoding: utf-8

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
     @averageBidders += tender.num_bidders.to_f
     @averageBids += tender.num_bids.to_f
    end
  end
  def calcAverages()
    if @averageBidDuration > 0
      @averageBidDuration = @averageBidDuration / @count
    end
    if @averageWarningPeriod > 0
      @averageWarningPeriod = @averageWarningPeriod / @count
    end
    if @averageBidders > 0
      @averageBidders = @averageBidders / @successCount
    end
    if @averageBids > 0
      @averageBids = @averageBids / @successCount
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

  def getNumTendersWithBidders
    return @successCount.to_f/@count.to_f
  end

  def getSuccessCount
    return @successCount
  end

  def getCountPair
    count = [@name, @count]
    return count
  end
  def getValuePair
    value = [@name, @value.to_i]
    return value
  end

  def getAverageBidDurationPair
    average = [@name, @averageBidDuration]
    return average
  end

  def getAverageWarningPeriodPair
    average = [@name, @averageWarningPeriod]
    return average
  end
end

class AnalysisController < ApplicationController
include GraphHelper 
  def index
    @years = []
    firstTender = Tender.limit(1).order("tender_announcement_date ASC")[0]
    firstYear = firstTender.tender_announcement_date.year
    lastYear = DateTime.now.year
    curYear = firstYear
    while curYear <= lastYear
      @years.push( curYear )
      curYear += 1
    end
    @years.push("All")
  end
  
  def generate
    tenders = nil
    if params[:year] == "All"
       tenders = Tender.find(:all)
    else
      startDate = params[:year]+"-01-01"
      endDate = params[:year]+"-12-31"
      tenders = Tender.where( "tender_announcement_date >= '"+startDate+"' AND tender_announcement_date <= '"+endDate+"'")
    end

    @total = TenderTypeStat.new("total")
    @simple_electronic = TenderTypeStat.new('Simple Electronic Tender')
    @electronic = TenderTypeStat.new('Electronic Tender')
    bidData = {}
    cpvAgreements = {}
    tenders.each do |tender|
      if tender.tender_type.strip() == "ელექტრონული ტენდერი"
        @electronic.addStats(tender)
      elsif tender.tender_type.strip() == "გამარტივებული ელექტრონული ტენდერი"
        @simple_electronic.addStats(tender)
        duration = tender.bid_end_date - tender.tender_announcement_date
       
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
    
      code = TenderCpvClassifier.where(:cpv_code => tender.cpv_code).first
      cpvDescription = nil
      if code
        cpvDescription = code.description_english
      end
      if cpvDescription == nil
        cpvDescription = "NA"
      end
      tender[:cpvDescription] = cpvDescription

      agreements = Agreement.find_all_by_tender_id(tender.id)
      #get last agreement
      lastAgreement = nil
      agreements.each do |agreement|
        if not lastAgreement or lastAgreement.amendment_number < agreement.amendment_number
          lastAgreement = agreement
        end
      end
      if lastAgreement
        item = { :name => tender.cpvDescription, :value => lastAgreement.amount, :code => tender.cpv_code, :children => [] }
        if not cpvAgreements[tender.cpv_code]
          cpvAgreements[tender.cpv_code] = item
        else
          old = cpvAgreements[tender.cpv_code]
          old[:value] += item[:value]
          cpvAgreements[tender.cpv_code] = old
        end
      end

      @total.addStats(tender)

      @bidDurationVsBidders = []
      bidData.each do |key,data|
        average = data[0].to_f / data[1].to_f
        dataPoint = [key,average,data[1].to_f]
        #if this average is made up of atleast %1 of all tenders
        if data[1] > @simple_electronic.getSuccessCount() / 100
          @bidDurationVsBidders.push( dataPoint )
        end
      end
        
    end

    @info = []
    @info.push( ["Number of Tenders", @total.getCount()] )
    orgCount = Organization.where(:is_bidder => true).count
    procCount = Organization.where(:is_procurer => true).count
    @info.push( ["Number of Organizations", orgCount] )
    @info.push( ["Number of Procurers", procCount] )
    @info.push( ["Number of contracts signed", @total.getAgreementCount()] )
    @info.push( ["Number of Bids", @total.getAverageBids().to_i] )
    

    @total.calcAverages()
    @simple_electronic.calcAverages()
    @electronic.calcAverages()

    @info.push( ["Average Number of Bids Per Tender", @total.getAverageBids()] )
    @info.push( ["Average Number of Bidders Per Tender", @total.getAverageBidders()] )

    @data = []
    @data.push(@simple_electronic)
    @data.push(@electronic)

    @jsonString = createTreeGraphStringFromAgreements( cpvAgreements )
    respond_to do |format|  
      format.js   
    end
  end

end
