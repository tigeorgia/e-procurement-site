class AddEmailAlertToWatchTenderAndSearch < ActiveRecord::Migration
  def up
    add_column :watch_tenders, :email_alert, :boolean
    add_column :searches, :email_alert, :boolean
  end

  def down
    remove_column :watch_tenders, :email_alert
    remove_column :searches, :email_alert
  end
end
