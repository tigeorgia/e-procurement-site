class CreateSimplifiedAttachments < ActiveRecord::Migration
  def change
    create_table :simplified_attachments do |t|
      t.references :simplified_tender
      t.string :title
      t.string :url

      t.timestamps
    end
    add_index :simplified_attachments, :simplified_tender_id
  end
end
