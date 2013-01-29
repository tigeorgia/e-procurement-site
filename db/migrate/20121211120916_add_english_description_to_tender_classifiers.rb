class AddEnglishDescriptionToTenderClassifiers < ActiveRecord::Migration
  def up
    add_column :tender_cpv_classifiers, :description_english, :string
  end

  def down
    remove_column :tender_cpv_classifiers, :description_english
  end
end
