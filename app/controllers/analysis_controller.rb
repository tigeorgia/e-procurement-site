#!/bin/env ruby
# encoding: utf-8

class TenderTypeStat
  def initialize(name) 
    @name = name 
    @count = 0
    @value = 0
    @averageBidDuration = 0
    @averageWarningPeriod = 0
  end 
  def addStats(tender)
    @count = @count + 1
    @value = @value + tender.estimated_value
    @averageBidDuration += (tender.bid_end_date - tender.bid_start_date).to_i
    @averageWarningPeriod += (tender.bid_start_date - tender.tender_announcement_date).to_i
  end
  def calcAverages()
    if @averageBidDuration > 0 
      @averageBidDuration = @averageBidDuration / @count
    end
    if @averageWarningPeriod > 0
      @averageWarningPeriod = @averageWarningPeriod / @count
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
    @procedure = TenderTypeStat.new('Electronic procurement procedure')
    @consolidated = TenderTypeStat.new('Consolidated Tender')

    tenders.each do |tender|
      if tender.tender_type.strip() == "ელექტრონული ტენდერი"
        @electronic.addStats(tender)
      elsif tender.tender_type.strip() == "გამარტივებული ელექტრონული ტენდერი"
        @simple_electronic.addStats(tender)
      elsif tender.tender_type.strip() == "კონსოლიდირებული ტენდერი"
        @consolidated.addStats(tender)
      else
        @procedure.addStats(tender)
      end
      @total.addStats(tender)
    end
    @total.calcAverages()
    @simple_electronic.calcAverages()
    @electronic.calcAverages()
    @procedure.calcAverages()
    @consolidated.calcAverages()

    @data = []
    @data.push(@simple_electronic)
    @data.push(@electronic)
    @data.push(@procedure)
    @data.push(@consolidated)
  end

end
