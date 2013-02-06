class CreateCorruptionIndicators < ActiveRecord::Migration
  def change
    create_table :corruption_indicators do |t|
      t.integer :weight
      t.string :description
      t.string :name
      t.timestamps
    end
  end
end
