class AddTranslationToCpvGroup < ActiveRecord::Migration
  def change
    add_column :cpv_groups, :translation, :string
  end
end
