class AddDescriptionToCpvClassifier < ActiveRecord::Migration
 def up
    add_column :tender_cpv_classifiers, :description, :string
  end

  def down
    remove_column :tender_cpv_classifiers, :description
  end
end
