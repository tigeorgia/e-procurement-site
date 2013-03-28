class AddTranslationToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :translation, :string
  end
end
