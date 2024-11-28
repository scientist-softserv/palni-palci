namespace :db do
  desc 'Dump each tenant schema to a separate file in the root directory after checking schema size'
  task dump_schemas: :environment do
    # Fetch database configuration from Rails environment
    db_config = Rails.configuration.database_configuration[Rails.env]

    pg_password = db_config['password']
    pg_user = db_config['username']
    pg_host = db_config['host']
    pg_port = db_config['port'] || '5432'
    db_name = db_config['database']

    # Set the PGPASSWORD environment variable
    ENV['PGPASSWORD'] = pg_password

    # Print the values for debugging
    puts "PGPASSWORD: #{ENV['PGPASSWORD']}"
    puts "PGUSER: #{pg_user}"
    puts "PGHOST: #{pg_host}"
    puts "PGPORT: #{pg_port}"
    puts "DB_NAME: #{db_name}"

    # Iterate over each account
    Account.find_each do |account|
      schema_name = account.tenant
      tenant_name = account.name
      tenant_id = account.id
      next if schema_name.blank? # Skip if the tenant is blank

      # Check the size of the schema
      result = ActiveRecord::Base.connection.execute("
        SELECT pg_size_pretty(sum(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))) AS total_size
        FROM pg_tables
        WHERE schemaname = '#{schema_name}';
      ")

      # Get the size from the result
      schema_size = result[0]['total_size']
      puts "tenant_id #{tenant_id}, tenant_name: #{tenant_name}, schema_name: #{schema_name} schema_size: #{schema_size}"

      # Define the output file path
      dump_file = "/app/samvera/hyrax-webapp/tmp/#{schema_name}_dump.sql"

      # Construct the pg_dump command
      command = "pg_dump -U #{pg_user} -h #{pg_host} -p #{pg_port} -d #{db_name} --schema='#{schema_name}' -f #{dump_file}"

      # Run the command
      puts "Dumping schema #{schema_name} to #{dump_file}"
      system(command)

      # Check if the command was successful
      if $?.exitstatus == 0
        puts "Successfully dumped schema #{schema_name}"
      else
        puts "Error dumping schema #{schema_name}"
      end
    end
  end
end