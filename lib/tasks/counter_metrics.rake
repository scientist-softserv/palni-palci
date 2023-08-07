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

  # bundle exec rake counter_metrics:import_requests['pittir.hykucommons.org','spec/fixtures/csv/pittir-downloads.csv']
  desc 'import historical counter investigations'
  task 'import_investigations', [:tenant_cname, :csv_path] => [:environment] do |_cmd, args|
    raise ArgumentError, 'A tenant cname is required: `rake counter_metrics:import_investigations[tenant_cname]`' if args.tenant_cname.blank?
    raise ArgumentError, "Tenant not found: #{args.tenant_cname}. Are you sure this is the correct tenant cname?" unless Account.where(cname: args.tenant_cname).first
    AccountElevator.switch!(args.tenant_cname)
    puts "Importing historical investigations for #{args.tenant_cname}"
    ImportCounterMetrics.import_investigations(args.csv_path)
  end
end
