class TendersDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Tenders.count,
      iTotalDisplayRecords: tenders.total_entries,
      aaData: data
    }
  end

private

  def data
    @results.each do |tender|
      [
        link_to(tender.name, tender)
      ]
    end
  end

  def tenders
    @Tenders ||= fetch_products
  end

  def fetch_products
    tenders = Tender.order("#{sort_column} #{sort_direction}")
    tenders = tenders.page(page).per_page(per_page)
    if params[:sSearch].present?
      tenders = tenders.where("name like :search or category like :search", search: "%#{params[:sSearch]}%")
    end
    tenders
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name category released_on price]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
