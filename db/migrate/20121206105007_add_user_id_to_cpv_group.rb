class AddUserIdToCpvGroup < ActiveRecord::Migration
  def up
    add_column :cpv_groups, :user_id, :integer
  end

  def down
    remove_column :cpv_groups, :user_id
  end
end
