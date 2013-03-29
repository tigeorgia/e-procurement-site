class CreateAggregateStatisticTypes < ActiveRecord::Migration
  def change
    create_table :aggregate_statistic_types do |t|
      t.integer :aggregate_statistic_id
      t.string :name
      t.timestamps
    end
  end
end
