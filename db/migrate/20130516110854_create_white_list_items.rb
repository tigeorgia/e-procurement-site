class CreateWhiteListItems < ActiveRecord::Migration
  def change
    create_table :white_list_items do |t|
      t.integer :organization_id
      t.string :organization_name
      t.string :issue_date
      t.string :agreement_url
      t.string :company_info_url
      t.timestamps
    end
  end
end
