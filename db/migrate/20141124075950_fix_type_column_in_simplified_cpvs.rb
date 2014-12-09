class FixTypeColumnInSimplifiedCpvs < ActiveRecord::Migration

  def change
    rename_column :simplified_cpvs, :type, :cpv_type
  end

end

