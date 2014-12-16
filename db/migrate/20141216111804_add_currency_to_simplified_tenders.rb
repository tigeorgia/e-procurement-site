class AddCurrencyToSimplifiedTenders < ActiveRecord::Migration
  def change
    add_column :simplified_tenders, :currency, :string
  end
end
