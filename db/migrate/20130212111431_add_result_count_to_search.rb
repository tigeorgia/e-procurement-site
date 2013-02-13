class AddResultCountToSearch < ActiveRecord::Migration
  def up
    add_column :searches, :count, :integer
  end

  def down
    remove_column :searches, :count
  end
end
