class AddProcurerAndSupplierNameToTender < ActiveRecord::Migration
  def change
    add_column :tenders, :procurer_name, :string
    add_column :tenders, :supplier_name, :string
  end
end
