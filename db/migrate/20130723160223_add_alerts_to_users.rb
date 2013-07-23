class AddAlertsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_alerts, :boolean
  end
end
