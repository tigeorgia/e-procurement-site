class AddContractSigningDateToSimplifiedTenders < ActiveRecord::Migration
  def change
    add_column :simplified_tenders, :contract_signing_date, :date
  end
end
