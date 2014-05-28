class ChangeStringFormatInOrganizations < ActiveRecord::Migration
  def up
    change_column :organizations, :code, :string
  end

  def down
    change_column :organizations, :code, :integer
  end
end
