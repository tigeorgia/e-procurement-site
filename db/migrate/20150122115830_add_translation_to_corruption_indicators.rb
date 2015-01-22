class AddTranslationToCorruptionIndicators < ActiveRecord::Migration
  def change
    add_column :corruption_indicators, :translation, :string
  end
end
