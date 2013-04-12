class AddMetaDataToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :total_won_contract_value, :integer, :precision => 11, :scale => 2
    add_column :organizations, :total_bid_tenders, :integer
    add_column :organizations, :total_won_tenders, :integer
    add_column :organizations, :total_offered_contract_value, :integer, :precision => 11, :scale => 2
    add_column :organizations, :total_offered_tenders, :integer
    add_column :organizations, :total_success_tenders, :integer
  end
end
