class CreateCpvGroupCpvClassifierJoinTable < ActiveRecord::Migration
  def change
    create_table :cpv_groups_tender_cpv_classifiers, :id => false do |t|
      t.integer :cpv_group_id
      t.integer :tender_cpv_classifier_id
    end
  end
end
