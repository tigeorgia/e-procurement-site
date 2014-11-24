class SimplifiedProcurementController < ApplicationController

  helper_method :sort_column, :sort_direction
  include ApplicationHelper
  include QueryHelper

  def index
    @procurement_status = [['Ongoing','Ongoing contract'],['Fulfilled','Fulfilled contract'],['Not fulfilled','Not fulfilled contract']]

  end

  def search
    @params = params

    results = QueryHelper.buildSimplifiedProcurementSearchQuery(params)


    @num_results = results.length
    @procurements = results.paginate(:page => params[:page]).order(sort_column + ' ' + sort_direction)

    render 'search'

  end

  def show
    @procurement = SimplifiedTender.find(params[:id])
    @timestamp = Time.now.strftime('%m%d%H%M%S%L')
  end

  private

  def sort_column
    params[:sort] || "registration_number"
  end

  def sort_direction
    params[:direction] || "asc"
  end

end
