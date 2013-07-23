class AddUpdateListToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :new_ids, :text
  end
end
