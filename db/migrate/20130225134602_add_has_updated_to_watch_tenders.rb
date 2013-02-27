class AddHasUpdatedToWatchTenders < ActiveRecord::Migration
  def up
    add_column :watch_tenders, :has_updated, :boolean
  end

  def down
    remove_column :watch_tenders, :has_updated
  end
end

