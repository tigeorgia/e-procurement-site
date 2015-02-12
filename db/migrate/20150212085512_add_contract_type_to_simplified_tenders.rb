class AddContractTypeToSimplifiedTenders < ActiveRecord::Migration
  def change
    add_column :simplified_tenders, :contract_type, :string
  end
end
