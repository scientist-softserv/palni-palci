namespace :counter_metrics do
  # bundle exec rake counter_metrics:import_investigations['pittir.hykucommons.org','spec/fixtures/csv/pittir-views.csv']
  desc 'import historical counter requests'
  task 'import_requests', [:tenant_cname, :csv_path] => [:environment] do |_cmd, args|
    raise ArgumentError, 'A tenant cname is required: `rake counter_metrics:import_requests[tenant_cname]`' if args.tenant_cname.blank?
    raise ArgumentError, "Tenant not found: #{args.tenant_cname}. Are you sure this is the correct tenant cname?" unless Account.where(cname: args.tenant_cname).first
    AccountElevator.switch!(args.tenant_cname)
    puts "Importing historical requests for #{args.tenant_cname}"
    ImportCounterMetrics.import_requests(args.csv_path)
  end

  desc 'import historical counter investigations'
  # bundle exec rake counter_metrics:import_requests['pittir.hykucommons.org','spec/fixtures/csv/pittir-downloads.csv']
  task 'import_investigations', [:tenant_cname, :csv_path] => [:environment] do |_cmd, args|
    raise ArgumentError, 'A tenant cname is required: `rake counter_metrics:import_investigations[tenant_cname]`' if args.tenant_cname.blank?
    raise ArgumentError, "Tenant not found: #{args.tenant_cname}. Are you sure this is the correct tenant cname?" unless Account.where(cname: args.tenant_cname).first
    AccountElevator.switch!(args.tenant_cname)
    puts "Importing historical investigations for #{args.tenant_cname}"
    ImportCounterMetrics.import_investigations(args.csv_path)
  end

  # You can optionally pass work IDs to have hyrax counter metrics created for specific works.
  # Or, you can pass a limit for the number of CounterMetric entries you would like to create. currently they are randomly created for GenericWorks.
  # Example for pitt tenant in dev without ids:
  # bundle exec rake counter_metrics:generate_staging_metrics[pitt.hyku.test]
  # Example with ids:
  # bundle exec rake counter_metrics:generate_staging_metrics[pitt.hyku.test,'ab3c1f9d-684a-4c14-93b1-75586ec05f7a']
  # Example with limit:
  # LIMIT=1 bundle exec rake counter_metrics:generate_staging_metrics[pitt.hyku.test]
  desc 'generate counter metric test data for staging'
  task 'generate_staging_metrics', [:tenant_cname, :ids] => [:environment] do |_cmd, args|
    raise ArgumentError, 'A tenant cname is required: `rake counter_metrics:generate_staging_metrics[tenant_cname]`' if args.tenant_cname.blank?
    raise ArgumentError, "Tenant not found: #{args.tenant_cname}. Are you sure this is the correct tenant cname?" unless Account.where(cname: args.tenant_cname).first
    ids = args.ids.present? ? args.ids.split("|") : []
    limit = ENV['LIMIT'].present? ? ENV['LIMIT'].to_i : 10
    raise ArgumentError, 'The ids argument must be an array: `bundle exec rake counter_metrics:generate_staging_metrics[tenant_cname, [ids], limit]' unless (ids.is_a?(Array))
    raise ArgumentError, 'limit argument must an integer. The default is 10' unless (limit.is_a?(Integer))
    AccountElevator.switch!(args.tenant_cname)
    puts "Creating test counter metric data for #{args.tenant_cname}"
    GenerateCounterMetrics.generate_counter_metrics(ids: ids, limit: limit)
    puts 'Test data created successfully'
  end
end
