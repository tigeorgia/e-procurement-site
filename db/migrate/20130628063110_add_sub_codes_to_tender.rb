class AddSubCodesToTender < ActiveRecord::Migration
  def change
    add_column :tenders, :sub_codes, :string
  end
end
