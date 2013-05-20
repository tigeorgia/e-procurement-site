class AddBwListFlagToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :bw_list_flag, :string
  end
end
