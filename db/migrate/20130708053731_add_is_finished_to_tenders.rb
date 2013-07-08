class AddIsFinishedToTenders < ActiveRecord::Migration
  def change
    add_column :tenders, :inProgress, :boolean
  end
end
