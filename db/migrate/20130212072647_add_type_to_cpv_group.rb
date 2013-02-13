class AddTypeToCpvGroup < ActiveRecord::Migration
  def up
    add_column :cpv_groups, :type, :string
  end

  def down
    remove_column :cpv_groups, :type
  end
end
