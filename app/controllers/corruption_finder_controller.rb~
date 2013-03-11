#!/bin/env ruby
# encoding: utf-8


class CorruptionFinderController < ApplicationController

  def index
    @indicators = CorruptionIndicator.find(:all)
  end

  def search
    indicator_id = params[:indicator_id]
    highRiskFlags = TenderCorruptionFlag.where(:corruption_indicator_id => indicator_id).order("value DESC").limit(100)
    indicator = CorruptionIndicator.find(indicator_id)

    @riskyTenders = []
    count = 0
    highRiskFlags.each do |flag|
      tenderData = {}
      tender = Tender.find(flag.tender_id)
      tenderData[:id] = tender.id
      tenderData[:code] = tender.tender_registration_number
      tenderData[:value] = flag.value * indicator.weight
      tenderData[:date] = tender.tender_announcement_date

      #get all indicators related to this tender if we are retriving all
      if indicator_id == "100"
        flags = TenderCorruptionFlag.where(:tender_id => tender.id)
        tenderData[:info] = ""
        flags.each do |flag|
          if not flag.corruption_indicator_id == 100
            tenderData[:info]+= CorruptionIndicator.find(flag.corruption_indicator_id).name+", "
          end
        end
        tenderData[:info].chop!.chop!
      else
        tenderData[:info] = indicator.name
      end
      @riskyTenders.push(tenderData)
    end

    respond_to do |format|  
      format.js   
    end
  end


=begin
      tenders = {}
      count = 0
      TenderCorruptionFlag.find_each do | flag |
        riskAssessment = tenders[flag.tender_id]
        if not riskAssessment
          riskAssessment = {}
          riskAssessment[:total] = 0
          riskAssessment[:indicators] = []
        end
        indicator = CorruptionIndicator.find( flag.corruption_indicator_id )
        riskAssessment[:total] = riskAssessment[:total] + (indicator.weight * flag.value)
        riskAssessment[:indicators].push(indicator)
        tenders[flag.tender_id] = riskAssessment
      end
      
      def mysort(a,b)
        if b[:total] > a[:total]
          return 1
        else
          return -1
        end
      end
      tenders = tenders.sort { |a,b| mysort(a[1],b[1])}
      
      @riskyTenders = []
      count = 0
      tenders.each do |tender_id, risk|
        count = count + 1
        if count > 25
          break
        end
        tenderData = {}
        tenderData[:id] = tender_id
        tenderData[:code] = Tender.find(tender_id).tender_registration_number
        tenderData[:value] = risk[:total]
        tenderData[:info] = ""
        risk[:indicators].each do |indicator|
          tenderData[:info]+=indicator.name+", "
        end
        tenderData[:info].chop!.chop!
        @riskyTenders.push(tenderData)
      end
=end
end
