module MysqlBigTableMigrationHelper
  
  # some methods to add and remove columns and indexes to large tables by bulk copying to a temp table
  
  def add_column_using_tmp_table(table_name, *args)
    with_tmp_table(table_name) do |tmp_table_name|
      begin
        add_column tmp_table_name, *args
      rescue ActiveRecord::StatementInvalid => e
        raise unless e.message.include?("Duplicate column name")
      end
    end
  end
  
  def remove_column_using_tmp_table(table_name, column_name)
    with_tmp_table(table_name) do |tmp_table_name|
      begin
        remove_column tmp_table_name, column_name
      rescue ActiveRecord::StatementInvalid => e
        raise unless e.message.include?("check that column/key exists")
      end
    end
  end
  
  def rename_column_using_tmp_table(table_name, column_name, new_column_name)
    with_tmp_table(table_name) { |tmp_table_name| rename_column(tmp_table_name, column_name, new_column_name) }
  end
  
  def add_index_using_tmp_table(table_name, column_name, options={})
    # generate the index name using the original table name if no name provided
    options[:name] = index_name(table_name, :column => Array(column_name)) if options[:name].nil? 
    with_tmp_table(table_name) { |tmp_table_name| add_index(tmp_table_name, column_name, options) }
  end
  
  def remove_index_using_tmp_table(table_name, options={})
    with_tmp_table(table_name) { |tmp_table_name| remove_index(tmp_table_name, :name => index_name(table_name, options)) }
  end
  
  private
  def with_tmp_table(table_name)
    
    raise ArgumentError "block expected" unless block_given?
    
    unless ActiveRecord::Base.connection.class.name == "ActiveRecord::ConnectionAdapters::MysqlAdapter"
      puts "Warning: Unsupported connection adapter '#{ActiveRecord::Base.connection.class.name}' for MySQLBigTableMigrationHelper."
      puts "         Methods will still be executed, but without using a temp table."
      yield table_name
      return
    end

    table_name = table_name.to_s
    new_table_name = "tmp_new_" + table_name
    old_table_name = "tmp_old_" + table_name
    
    begin

      puts "Creating temporary table #{new_table_name} like #{table_name}..."
      ActiveRecord::Base.connection.execute("CREATE TABLE #{new_table_name} LIKE #{table_name}")
    
      # yield the temporary table name to the block, which should alter the table using standard migration methods
      yield new_table_name 
    
      # get column names to copy *after* yielding to block - could drop a column from new table
      # note: do not get column names using the column_names method, we need to make sure we avoid obtaining a cached array of column names
      old_column_names = [] 
      ActiveRecord::Base.connection.execute("DESCRIBE #{table_name}").each_hash{ |row| old_column_names << row['Field'] } # see ruby mysql docs for more info
      new_column_names = []
      ActiveRecord::Base.connection.execute("DESCRIBE #{new_table_name}").each_hash{ |row| new_column_names << row['Field'] }

      # columns to copy is intersection of old and new - i.e. only columns in both tables
      columns_to_copy = "`" + ( old_column_names & new_column_names ).join("`, `") + "`"

      timestamp_before_migration = ActiveRecord::Base.connection.execute("SELECT CURRENT_TIMESTAMP").fetch_row[0] # note: string, not time object
      max_id_before_migration = ActiveRecord::Base.connection.execute("SELECT MAX(id) FROM #{table_name}").fetch_row[0].to_i
      
      batch_size = 10000
      counter = 0
      puts "Inserting into temporary table in batches of #{batch_size}..."
      while counter < ActiveRecord::Base.connection.execute("SELECT MAX(id) FROM #{table_name}").fetch_row[0].to_i 
        puts "Processing rows with ids between #{counter+1} and #{counter+batch_size}"
        ActiveRecord::Base.connection.execute("INSERT INTO #{new_table_name} (#{columns_to_copy}) SELECT #{columns_to_copy} FROM #{table_name} WHERE id > #{counter} AND id <= #{counter + batch_size}")
        counter = counter + batch_size
      end
      
    rescue Exception => e
      drop_table new_table_name
      raise
    end      
    
    puts "Replacing source table with temporary table..."
    rename_table table_name, old_table_name
    rename_table new_table_name, table_name
    
    puts "Cleaning up, checking for rows created/updated during migration, dropping old table..."
    begin
      ActiveRecord::Base.connection.execute("LOCK TABLES #{table_name} WRITE, #{old_table_name} READ")
      recently_created_or_updated_conditions = "id > #{max_id_before_migration}"
      recently_created_or_updated_conditions << " OR updated_at > '#{timestamp_before_migration}'" if old_column_names.include?(:updated_at)
      ActiveRecord::Base.connection.execute("REPLACE INTO #{table_name} (#{columns_to_copy}) SELECT #{columns_to_copy} FROM #{old_table_name} WHERE #{recently_created_or_updated_conditions}")
    rescue Exception => e
      puts "Failed to lock tables and do final cleanup. This may not be anything to worry about, especially on an infrequently used table."
      puts "ERROR MESSAGE: " + e.message
    ensure
      ActiveRecord::Base.connection.execute("UNLOCK TABLES")
    end
    drop_table old_table_name
  end
  
end
