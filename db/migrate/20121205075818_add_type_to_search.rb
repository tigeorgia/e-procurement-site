class AddTypeToSearch < ActiveRecord::Migration
def up
    add_column :searches, :searchtype, :string
  end

  def down
    remove_column :searches, :searchtype
  end
end
