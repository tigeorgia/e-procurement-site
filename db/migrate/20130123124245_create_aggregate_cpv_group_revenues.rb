class CreateAggregateCpvGroupRevenues < ActiveRecord::Migration
  def change
    create_table :aggregate_cpv_group_revenues do |t|

      t.timestamps
    end
  end
end
