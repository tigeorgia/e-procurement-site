class CreateCpvGroups < ActiveRecord::Migration
  def change
    create_table :cpv_groups do |t|

      t.timestamps
    end
  end
end
