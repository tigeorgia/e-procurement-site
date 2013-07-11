namespace :procurement do
  desc "Processes Json data retrived from a web scrape and inputs results into a database"
  task:full_scrape => :environment do
    require "scraper_file"
    ScraperFile.processScrape
  end
  
  desc "Use for testing scraper functions"
  task:incremental_scrape => :environment do
    require "scraper_file"
    ScraperFile.testProcess
  end

  desc "called on remote server to send email alerts"
  task:generate_alerts => :environment do
    require "scraper_file"
    ScraperFile.generateAlertDigests
  end


  desc "Process meta data and store results in db"
  task:buildMetaData=> :environment do
    require "scraper_file"
    ScraperFile.buildUserDataOnly
  end


  desc "do debug tasks"
  task:test_code => :environment do
    require "test_code"
    TestFile.run
  end

  desc "save user data"
  task:export_users => :environment do
    require "user_migrator"
    UserMigrator.createMigrationFile
  end
  
  desc "import user data"
  task:import_users => :environment do
    require "user_migrator"
    UserMigrator.migrate
  end

end
