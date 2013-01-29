class AddAmendmentNumberToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :amendment_number, :integer
  end
end
