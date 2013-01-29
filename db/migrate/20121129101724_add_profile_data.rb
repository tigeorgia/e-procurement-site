class AddProfileData < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.integer :user_id
      t.string :search_string

      t.timestamps
    end

    create_table :watch_tenders do |t|
      t.integer :user_id
      t.string :tender_url

      t.timestamps
    end
  end
end
