require 'mysql_big_table_migration_helper'

class AddIndexOnStatusToSimplifiedTenders < ActiveRecord::Migration

  extend MysqlBigTableMigrationHelper

  def self.up
    add_index_using_tmp_table :simplified_tenders, :status
  end

  def self.down
    remove_index_using_tmp_table :simplified_tenders, :status
  end

end
