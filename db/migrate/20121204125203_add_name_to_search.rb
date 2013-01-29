class AddNameToSearch < ActiveRecord::Migration
  def up
    add_column :searches, :name, :string
  end

  def down
    remove_column :searches, :name
  end
end
