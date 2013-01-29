class AddNameToCpvGroup < ActiveRecord::Migration
  def up
    add_column :cpv_groups, :name, :string
  end

  def down
    remove_column :cpv_groups, :name
  end
end
