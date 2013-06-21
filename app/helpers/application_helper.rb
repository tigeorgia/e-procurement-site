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
    link_to title, myParams, :class => cssClass + " "+column
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
      results = Search.where( :user_id => current_user.id, :searchtype => type, :search_string => @thisSearchString )
      if results.count > 0
        @searchIsSaved = true
        @savedName = results.first.name
      end
    end
  end

  def buildTenderCSVString( tenders )
    CSV.open("/assets/tenders.csv", "wb") do |csv|
       csv << BOM
       csv << ["Type","Registration Number","Status", "Announcement Date", "Bidding Start Date", "Bidding End Date", "Estimated Value",
               "Cpv Code","Number of Bids","Number of Bidders","Bid Step","Units Supplied","Supply Period","Guarantee Amount","Guarantee Period"]
       tenders.each do |tender|
         csv << [tender.tender_type,tender.tender_registration_number,tender.tender_status,tender.tender_announcement_date,tender.bid_start_date,
                tender.bid_end_date, tender.estimated_value, tender.cpv_code, tender.num_bids, tender.num_bidders, tender.offer_step,
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
