class CreateProcurerCpvRevenues < ActiveRecord::Migration
  def change
    create_table :procurer_cpv_revenues do |t|
      t.integer :id
      t.integer :organization_id
      t.string :cpv_code
      t.decimal :total_value, :precision => 11, :scale => 2   
      t.timestamps
    end
  end
end
