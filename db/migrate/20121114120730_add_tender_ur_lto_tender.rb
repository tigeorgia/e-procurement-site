class AddTenderUrLtoTender < ActiveRecord::Migration
  def up
    add_column :tenders, :url_id, :integer
  end

  def down
    remove_column :tenders, :url_id
  end
end
