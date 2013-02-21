module QueryHelper 


   def self.buildSearchParamsFromString(searchString)
    fields = searchString.split("#")
    params = {
      :cpvGroup => fields[0],
      :datasetID => fields[1],
      :tender_registration_number => fields[2],
      :tender_status => fields[3],
      :announced_after => fields[4],
      :announced_before => fields[5],
      :min_estimate => fields[6],
      :max_estimate => fields[7],
      :min_num_bids => fields[8],
      :max_num_bids => fields[9],
      :min_num_bidders => fields[10],
      :max_num_bidders => fields[11]
    }
    return params
  end


 def self.buildTenderSearchQuery(params)
    #all params should already be in string format
    query = "dataset_id = '" +params[:datasetID]+"'"+
        " AND tender_registration_number LIKE '"+params[:tender_registration_number]+"'"+
        " AND tender_status LIKE '"+params[:tender_status]+"'"+
        " AND tender_announcement_date >= '"+params[:announced_after]+"'"+
        " AND tender_announcement_date <= '"+params[:announced_before]+"'"+
        " AND estimated_value >= '"+params[:min_estimate]+"'"+
        " AND estimated_value <= '"+params[:max_estimate]+"'"+
        " AND num_bids >= '"+params[:min_num_bids]+"'"+
        " AND num_bids <= '"+params[:max_num_bids]+"'"+
        " AND num_bidders >= '"+params[:min_num_bidders]+"'"+
        " AND num_bidders <= '"+params[:max_num_bidders]+"'"

    cpvGroup = CpvGroup.where(:id => params[:cpvGroupID]).first
    if not cpvGroup or cpvGroup.id == 1
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

end
