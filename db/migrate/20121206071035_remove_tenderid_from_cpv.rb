class RemoveTenderidFromCpv < ActiveRecord::Migration
  def up
    remove_index :tender_cpv_classifiers, :tender_id
    remove_column :tender_cpv_classifiers, :tender_id
  end

  def down
    add_column :tender_cpv_classifiers, :tender_id, :integer
    add_index :tender_cpv_classifiers, :tender_id
  end
end

