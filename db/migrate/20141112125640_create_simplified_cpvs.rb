class CreateSimplifiedCpvs < ActiveRecord::Migration
  def change
    create_table :simplified_cpvs do |t|
      t.references :simplified_tender
      t.string :title
      t.string :type
      t.string :code

      t.timestamps
    end
    add_index :simplified_cpvs, :simplified_tender_id
  end
end
