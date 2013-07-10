class AddCpvTreeGraphToAggregateStatistics < ActiveRecord::Migration
  def change
    add_column :aggregate_statistics, :cpvString, :text, :limit => 64.kilobytes + 1 #medium text
  end
end
