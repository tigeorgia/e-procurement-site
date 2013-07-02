class CpvCodeCodeFromIntToString < ActiveRecord::Migration
  def up
    remove_column :tender_cpv_codes, :cpv_code
    add_column :tender_cpv_codes, :cpv_code, :string
  end
  def down
    remove_column :tender_cpv_codes, :cpv_code
    add_column :tender_cpv_codes, :cpv_code, :integer
  end
end
