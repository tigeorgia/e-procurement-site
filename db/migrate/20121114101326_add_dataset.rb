class AddDataset < ActiveRecord::Migration
  def up
    create_table :datasets do |t|
      t.datetime :date
      t.boolean :is_live
      t.timestamps
    end
    add_column :tenders, :dataset_id, :integer
    add_column :organizations, :dataset_id, :integer
  end

  def down
    drop_table :datasets
    remove_column :tenders, :dataset_id
    remove_column :organizations, :dataset_id
  end
end
