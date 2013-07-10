class ChangeTenderSubCodesToText < ActiveRecord::Migration
  def up
    change_column :tenders, :sub_codes, :text
  end

  def down
    change_column :tenders, :sub_codes, :string
  end
end
