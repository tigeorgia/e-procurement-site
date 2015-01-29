class SimplifiedProcurementController < ApplicationController

  helper_method :sort_column, :sort_direction
  include ApplicationHelper
  include QueryHelper

  def index
    @procurement_status = [[t('ongoing'),'Ongoing contract'],[t('fulfilled'),'Fulfilled contract'],[t('not_fulfilled'),'Not fulfilled contract'],[t('no_status_yet'),'none']]

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
    SimplifiedTender.column_names.include?(params[:sort_by]) ? params[:sort_by] : 'registration_number'
  end

  def sort_direction
    %w{asc desc}.include?(params[:direction]) ? params[:direction] : 'asc'
  end

end
