class CreateBlackListItems < ActiveRecord::Migration
  def change
    create_table :black_list_items do |t|
      t.integer :organization_id
      t.string :organization_name
      t.string :issue_date
      t.string :procurer_name
      t.integer :procurer_id
      t.string :tender_id
      t.string :tender_number
      t.string :reason
      t.timestamps
    end
  end
end
