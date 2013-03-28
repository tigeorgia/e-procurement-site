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
end
