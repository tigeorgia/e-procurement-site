class AddFinancingSourceToSimplifiedTenders < ActiveRecord::Migration
  def change
    add_column :simplified_tenders, :financing_source, :string
  end
end
