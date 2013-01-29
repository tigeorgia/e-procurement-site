class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer :tender_id
      t.string :document_url

      t.timestamps
    end
  end
end
