class FixHashColumns < ActiveRecord::Migration
 def change
    rename_column :watch_tenders, :hash, :diff_hash
    rename_column :supplier_watches, :hash, :diff_hash
    rename_column :procurer_watches, :hash, :diff_hash
  end
end
