class CreateAggregateStatistics < ActiveRecord::Migration
  def change
    create_table :aggregate_statistics do |t|
      t.integer :year
      t.timestamps
    end
  end
end
