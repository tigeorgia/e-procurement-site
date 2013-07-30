class AddLastDataUpdateToWatches < ActiveRecord::Migration
  def change
    add_column :watch_tenders, :last_data_update, :datetime
    add_column :procurer_watches, :last_data_update, :datetime
    add_column :supplier_watches, :last_data_update, :datetime
    add_column :searches, :last_data_update, :datetime
  end
end
