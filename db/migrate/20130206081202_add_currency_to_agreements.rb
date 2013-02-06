class AddCurrencyToAgreements < ActiveRecord::Migration
 def up
    add_column :agreements, :currency, :string
  end

  def down
    remove_column :agreements, :currency
  end
end
