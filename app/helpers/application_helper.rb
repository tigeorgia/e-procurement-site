module ApplicationHelper

  def sortable(params, column, title = nil)
    myParams = params.clone
    title ||= column.titleize
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    myParams[:sort] = column
    myParams[:direction] = direction
    link_to title, myParams
  end


  def buildTenderCSVString( tenders )
    csv_string = CSV.generate do |csv|
       csv << ["Type","Registration Number","Status", "Announcement Date", "Bidding Start Date", "Bidding End Date", "Estimated Value",
               "Cpv Code","Number of Bids","Number of Bidders","Bid Step","Units Supplied","Supply Period","Guarantee Amount","Guarantee Period"]
       tenders.each do |tender|
         csv << [tender.tender_type,tender.tender_registration_number,tender.tender_status,tender.tender_announcement_date,tender.bid_start_date,
                tender.bid_end_date, tender.estimated_value, tender.cpv_code, tender.num_bids, tender.num_bidders, tender.offer_step,
                tender.units_to_supply,tender.supply_period,tender.guarantee_amount,tender.guarantee_period]
       end
      end
    return csv_string
  end

  def buildTenderSearchQuery(params)
    #all params should already be in string format
    query = "dataset_id = '" +params[:datasetID]+"'"+
        " AND tender_registration_number LIKE '"+params[:registration_number]+"'"+
        " AND tender_status LIKE '"+params[:tender_status]+"'"+
        " AND tender_announcement_date >= '"+params[:announced_after]+"'"+
        " AND tender_announcement_date <= '"+params[:announced_before]+"'"+
        " AND estimated_value >= '"+params[:minVal]+"'"+
        " AND estimated_value <= '"+params[:maxVal]+"'"+
        " AND num_bids >= '"+params[:min_bids]+"'"+
        " AND num_bids <= '"+params[:max_bids]+"'"+
        " AND num_bidders >= '"+params[:num_bidders]+"'"+
        " AND num_bidders <= '"+params[:num_bidders]+"'"

    cpvGroup = CpvGroup.find(params[:cpvGroupID]) 
    if not cpvGroupID or cpvGroup.id == 1
    else      
      cpvCategories = cpvGroup.tender_cpv_classifiers
      count = 1
      cpvCategories.each do |category|
        conjunction = " AND ("
        if count > 1
          conjunction = " OR"
        end
        query = query + conjunction+" cpv_code = "+category.cpv_code
        count = count + 1
      end
      query = query + " )"
    end
    return query
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
