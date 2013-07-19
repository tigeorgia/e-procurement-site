class AddUpdateTimeToDataset < ActiveRecord::Migration
  def change
     add_column :datasets, :data_valid_from, :datetime
     add_column :datasets, :next_update, :datetime
  end
end
