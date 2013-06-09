class AddResultToBidders < ActiveRecord::Migration
  def change
    add_column :bidders, :result, :string
  end
end
