class CreateTenderCpvClassifiers < ActiveRecord::Migration
  def change
    create_table :tender_cpv_classifiers do |t|
      t.integer :tender_id
      t.string :cpv_code

      t.timestamps
    end
    
    add_index :tender_cpv_classifiers, :tender_id
  end
end
