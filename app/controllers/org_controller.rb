  BOM = "\uFEFF" #Byte Order Mark

  def search
    @params = params
    name = params[:organization][:name]
    code = params[:organization][:code]
    org_type = params[:org_type]
    
    willSearchName = name.length > 0
    name = "%"+name+"%"
    code = "%"+code+"%"
    
    foreignOnly = params[:isForeign][:foreign]

    orgString = ""
    if not org_type == ""
      orgString = " AND org_type = '"+org_type+"'"
    end
    conditions = "is_bidder = true AND code LIKE '"+code +"'"+ orgString
    if foreignOnly == '1'
      conditions += " AND country NOT LIKE 'საქართველო'"
    end
    if willSearchName
      conditions += " AND ( name LIKE '"+name+"' OR translation LIKE '"+name+"' )"
    end
    
    results = Organization.where(conditions)
    @numResults = results.count
    @organizations = results.paginate(:page => params[:page]).order(sort_column + ' ' + sort_direction)

    respond_to do |format|
      format.html
      format.csv {   
        sendCSV(results, "organizations")
      }
    end 
  end

  def sendCSV( results, name )
    csv_data = CSV.generate() do |csv|
      csv << ["Name","Country","Legal Type","City","Address","Phone Number","Fax Number","Email","Web Page","Code"]
      results.each do |org|
       csv << [org.name,org.country,org.org_type,org.city,org.address,org.phone_number,org.fax_number,org.email,
               org.webpage,org.code]
      end
    end

    filename = name+".csv"
    content = BOM + csv_data
    send_data content, :filename => filename
  end
