# rake counter_metrics:import_requests['pittir.commons-archive.test']
namespace :counter_metrics do
  desc 'import historical counter requests'
  task 'import_requests', [:tenant_cname] => [:environment] do |_cmd, args|
    raise ArgumentError, 'A tenant cname is required: `rake counter_metrics:import_requests[tenant_cname]`' if args.tenant_cname.blank?
    raise ArgumentError, "Tenant not found: #{args.tenant_cname}. Are you sure this is the correct tenant cname?" unless Account.where(cname: args.tenant_cname).first
    AccountElevator.switch!(args.tenant_cname)
    puts "Importing historical requests for #{args.tenant_cname}" 
    ImportCounterMetrics.import_requests
  end

  desc 'import historical counter investigations'
  task 'import_investigations', [:tenant_cname] => [:environment] do |_cmd, args|
    raise ArgumentError, 'A tenant cname is required: `rake counter_metrics:import_investigations[tenant_cname]`' if args.tenant_cname.blank?
    raise ArgumentError, "Tenant not found: #{args.tenant_cname}. Are you sure this is the correct tenant cname?" unless Account.where(cname: args.tenant_cname).first
    AccountElevator.switch!(args.tenant_cname)
    puts "Importing historical investigations for #{args.tenant_cname}" 
    ImportCounterMetrics.import_investigations
  end
end
