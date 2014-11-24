class RemoveSimplifiedTenderRefFromSimplifiedCpv < ActiveRecord::Migration
  def up
    remove_column :simplified_cpvs, :simplified_tender_id
  end

  def down
    add_column :simplified_cpvs, :simplified_tender_id, :references
  end
end
