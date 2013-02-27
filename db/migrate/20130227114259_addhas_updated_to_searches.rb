class AddhasUpdatedToSearches < ActiveRecord::Migration
  def up
    add_column :searches, :has_updated, :boolean
  end

  def down
    remove_column :searches, :has_updated
  end
end
