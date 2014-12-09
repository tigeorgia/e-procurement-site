class AddWebIdToSimplifiedTenders < ActiveRecord::Migration
  def change
    add_column :simplified_tenders, :web_id, :integer
  end
end
