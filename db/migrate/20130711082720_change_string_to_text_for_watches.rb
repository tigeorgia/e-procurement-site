class ChangeStringToTextForWatches < ActiveRecord::Migration
  def up
    change_column :watch_tenders, :diff_hash, :text
    change_column :supplier_watches, :diff_hash, :text
    change_column :procurer_watches, :diff_hash, :text
  end

  def down
    change_column :watch_tenders, :diff_hash, :string
    change_column :supplier_watches, :diff_hash, :string
    change_column :procurer_watches, :diff_hash, :string
  end
end
