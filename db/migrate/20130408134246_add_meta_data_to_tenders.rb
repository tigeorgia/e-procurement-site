class AddMetaDataToTenders < ActiveRecord::Migration
  def change
    add_column :tenders, :winning_org_id, :integer
  end
end
