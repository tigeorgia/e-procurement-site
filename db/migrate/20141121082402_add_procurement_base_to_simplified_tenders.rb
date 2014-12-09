class AddProcurementBaseToSimplifiedTenders < ActiveRecord::Migration
  def change
    add_column :simplified_tenders, :procurement_base, :string
  end
end
