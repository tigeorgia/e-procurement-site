class AddLastViewedToSearches < ActiveRecord::Migration
  def up
    add_column :searches, :last_viewed, :datetime
  end

  def down
    remove_column :searches, :last_viewed
  end
end
