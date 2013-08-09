class AddCpvstringGeoToAggregateStats < ActiveRecord::Migration
  def change
    add_column :aggregate_statistics, :cpvStringGEO, :text, :limit =>  64.kilobytes + 1 #medium text
  end
end
