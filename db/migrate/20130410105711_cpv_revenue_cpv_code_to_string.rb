class CpvRevenueCpvCodeToString < ActiveRecord::Migration
  def up
    remove_column :aggregate_cpv_revenues, :cpv_code
    add_column :aggregate_cpv_revenues, :cpv_code, :string
  end

  def down
    remove_column :aggregate_cpv_revenues, :cpv_code
    add_column :aggregate_cpv_revenues, :cpv_code, :integer
  end
end
