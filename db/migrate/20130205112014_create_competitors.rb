class CreateCompetitors < ActiveRecord::Migration
  def change
    create_table :competitors do |t|
      t.integer :organization_id
      t.integer :rival_org_id
      t.integer :num_tenders
      t.timestamps
    end
  end
end
