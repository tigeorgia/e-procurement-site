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
  end
  def addStats(tender)
    @count = @count + 1
    @value = @value + tender.estimated_value
    @averageBidDuration += (tender.bid_end_date - tender.bid_start_date).to_f
    @averageWarningPeriod += (tender.bid_start_date - tender.tender_announcement_date).to_f
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
  def getCount
    return @count
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

  def index 
    tenders = Tender.where( "tender_announcement_date >= '2013-01-01' AND tender_announcement_date <= '2013-12-31'")
    @total = TenderTypeStat.new("total")
    @simple_electronic = TenderTypeStat.new('Simple Electronic Tender')
    @electronic = TenderTypeStat.new('Electronic Tender')
    bidData = {}

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
    @total.calcAverages()
    @simple_electronic.calcAverages()
    @electronic.calcAverages()

    @data = []
    @data.push(@simple_electronic)
    @data.push(@electronic)
  end

end
