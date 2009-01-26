namespace :init do

  desc "Initialize all the basic stuff"
  task :all => [ 'init:config_files', 'environment', 'init:drop_dbs', 'db:create:all', 'db:migrate', 'db:test:clone', 'test', 'populate:all'] do
  end
  
  desc "drop all databases if exists"
  task :drop_dbs => [:environment] do
    puts "Drop databases"
    Rake::Task['db:drop:all'].execute rescue nil
  end
  
  
  desc "Initilizing config files"
  task :config_files do
    puts ENV.inspect
    unless ENV.include?('db') || !['mysql','sqlite'].include?( ENV['db'] )
      raise "usage: rake db=<mysql|sqlite>" 
    end
    
    puts "initilizing database.yml with #{ENV['db']}..."
    FileUtils.copy_file\
      "#{RAILS_ROOT}/config/database.yml.#{ENV['db']}",
      "#{RAILS_ROOT}/config/database.yml"
      
    puts "initilizing site_keys.rb..."
    FileUtils.copy_file\
      "#{RAILS_ROOT}/config/initializers/site_keys.rb.example",
      "#{RAILS_ROOT}/config/initializers/site_keys.rb"

    puts "Please revise this file: /config/config.yml"
    puts "# /config/config.yml"
    puts File.read( "#{RAILS_ROOT}/config/config.yml" )
    
    puts "Please press enter to continue"
    $stdin.gets
  end
  
  desc "Reset databases to actual migrate state"
  task :reset_dbs => [:environment] do
    # raise RAILS_ENV
    
    # puts "Drop databases"
    # Rake::Task['db:drop:all'].execute rescue nil
    # 
    # puts "Create databases"
    # Rake::Task['db:create:all'].execute
    
    puts "Run migrations"
    Rake::Task['db:migrate'].execute
    
    puts "Undo migrations to VERSION=0"
    ENV['VERSION']='0'
    Rake::Task['db:migrate'].execute
    
    puts "Re-Run migrations"
    Rake::Task['db:migrate'].execute
      
    puts "Clone test db"
    Rake::Task['db:test:clone'].execute
  end
  
  desc "Run migrations"
  task :run_migrations => [:environment] do
    puts "Create databases"
    Rake::Task['db:create:all'].execute

    puts "ejecutando migraciones"
    RAILS_ENV='development'
    Rake::Task['db:migrate'].execute
  end
end