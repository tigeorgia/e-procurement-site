class RemoveDateFromDatasets < ActiveRecord::Migration
  def up
    remove_column :datasets, :date
  end

  def down
    add_column :datasets, :date, :datetime
  end
end
