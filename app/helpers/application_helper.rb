#!/bin/env ruby
# encoding: utf-8

module ApplicationHelper
  BOM = "\uFEFF" #Byte Order Mark
  def dropZeros( string )
    digits = countZeros(string)
    return string[0, string.length-digits]
  end

  def countZeros( string )
    count = 0
    pos = string.length
    while pos > 0
      if string[pos-1] == '0'
        count = count +1
      else
        break
      end
      pos = pos - 1
    end
    return count
  end


  def sortable(params, column, title = nil, cssClass = "arrow-link")
    myParams = params.clone
    title ||= column.titleize
    direction = (column == sort_column && sort_direction == "desc") ? "asc" : "desc"
    myParams[:sort] = column
    myParams[:direction] = direction
    link_to title, myParams, :class => cssClass + " " + column
  end

  def checkSavedSearch( attributes, type )
    if current_user
      searches = current_user.searches
      delim = '#'
      @thisSearchString = ""
      attributes.each do |field|
        if not field or field == ""
          field = "_"
        end
        @thisSearchString += field + "#"
      end
      puts "search string: " + @thisSearchString
      results = Search.where( :user_id => current_user.id, :searchtype => type, :search_string => @thisSearchString )
      if results.count > 0
        @searchIsSaved = true
        @search = results.first
        puts "testss"
        @savedName = @search.name
      end
    end
  end

  def buildTenderCSVString( tenders )
    CSV.open("/assets/tenders.csv", "w") do |csv|
       csv << BOM
       csv << [ t("Procurer"),t("Tender Type"),t("Tender Registration Number"),t("Status"), t("Announcement Date"), t("Bid Start Date"), t("Bid End Date"), t("Procurer Estimate"),
               t("Contract Value"),t("Supplier"),t("CPV Code"),t("Number Of Bids"),t("Number Of Bidders"),t("Bid Step"),t("Units Supplied"),t("Supply Period"),t("Guarantee Amount"),t("Guarantee Period")]
       tenders.each do |tender|
         csv << [tender.procurer_name,tender.tender_type,tender.tender_registration_number,tender.tender_status,tender.tender_announcement_date,tender.bid_start_date,
                tender.bid_end_date, tender.estimated_value,tender.contract_value,tender.supplier_name, tender.cpv_code, tender.num_bids, tender.num_bidders, tender.offer_step,
                tender.units_to_supply,tender.supply_period,tender.guarantee_amount,tender.guarantee_period]
       end
    end
  end

  def buildCSVString( column_headers, data )
    csv_string = CSV.generate do |csv|
      csv << column_headers
      data.each do |data|
       csv << data
      end
    end
    return BOM + csv_string
  end

  #takes a list of model instances and creates a csv string
  def buildCSVStringFromObjectList( objects, ignores )
    csv_string = CSV.generate do |csv|
      #use the first object to get the column names
      object = objects[0]
      column_header = []
      object.attributes.each do |attribute|
        if not ignores.include?(attribute[0])
          column_header.push(attribute[0])
        end
      end
      csv << column_header
      #now go through each object and print out the column values
      objects.find_each do |item|
        values = []
        item.attributes.each do |attribute|
          if not ignores.include?(attribute[0])
            values.push(attribute[1])
          end
        end
        csv << values
      end
    end
    return BOM + csv_string
  end

  #this is a expensive process that will combine all information avaiable able a tender including bidders and agreements and store each tender on a single csv row
  def buildTenderInfoCSVStringFromTenderList( tenders, ignores, filePath )
    csv_string = CSV.open(filePath,'w') do |csv|
      csv << [BOM]
      #use the first object to get the column names
      object = tenders[0]
      column_header = []
      maxBidders = Tender.order("num_bidders DESC").first.num_bidders      
      object.attributes.each do |attribute|
        if not ignores.include?(attribute[0])
          column_header.push(attribute[0])
        end
      end
      
      column_header.push("procurer_code")
      column_header.push("winner_code")
      for num in 0..maxBidders do
        column_header.push("bidder_"+num.to_s+"_name")
        column_header.push("bidder_"+num.to_s+"_id")
        column_header.push("bidder_"+num.to_s+"_lowest_bid")
        column_header.push("bidder_"+num.to_s+"_black_or_white")
      end
      
      csv << column_header
      #now go through each object and print out the column values
      tenders.find_each do |tender|
        values = []
        tender.attributes.each do |attribute|
          if not ignores.include?(attribute[0])
            values.push(attribute[1])
          end
        end
        
        tempBidders = []
        winningCode = nil
        procurerCode = nil
        procurer = Organization.where(:id => tender.procurring_entity_id).first
        if procurer
          procurerCode = procurer.code
        end
        values.push(procurerCode)

        bidders = Bidder.where(:tender_id => tender.id)
        bidders.each do |bidder|
          org = Organization.where(:id => bidder.organization_id).first
          if org.id == tender.winning_org_id
            winningCode = org.code
          end
          tempBidders.push(org.name)
          tempBidders.push(org.code)
          tempBidders.push(bidder.last_bid_amount)
          tempBidders.push(org.bw_list_flag)
        end

        values.push(winningCode)
        tempBidders.each do |data|
          values.push(data)
        end
        csv << values
      end
    end
  end


      
  def title(page_title)
    content_for(:title) { page_title }
  end

	def flash_translation(level)
    case level
    when :notice then "alert-info"
    when :success then "alert-success"
    when :error then "alert-error"
    when :alert then "alert-error"
    end
  end

	# from http://www.kensodev.com/2012/03/06/better-simple_format-for-rails-3-x-projects/
	# same as simple_format except it does not wrap all text in p tags
	def simple_format_no_tags(text, html_options = {}, options = {})
		text = '' if text.nil?
		text = smart_truncate(text, options[:truncate]) if options[:truncate].present?
		text = sanitize(text) unless options[:sanitize] == false
		text = text.to_str
		text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
#		text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
		text.html_safe
	end


	# Based on https://gist.github.com/1182136
  class BootstrapLinkRenderer < ::WillPaginate::ActionView::LinkRenderer
    protected

    def html_container(html)
      tag :div, tag(:ul, html), container_attributes
    end

    def page_number(page)
      tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
    end

    def gap
      tag :li, link(super, '#'), :class => 'disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || '#'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
    end
  end

  def page_navigation_links(pages)
    will_paginate(pages, :class => 'pagination', :inner_window => 2, :outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label => '&larr;'.html_safe, :next_label => '&rarr;'.html_safe)
  end

end
