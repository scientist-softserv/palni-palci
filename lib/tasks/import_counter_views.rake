# frozen_string_literal: true

namespace :counter_metrics do
  desc 'import historical counter views'
  task :import_views, [:tenant_cname] => :environment do |_cmd, args|
    raise ArgumentError, 'A tenant cname is required: `rake counter_metrics:import_views[tenant_cname]`' if args.tenant_cname.blank?
    raise ArgumentError, "Tenant not found: #{args.tenant_cname}. Are you sure this is the correct tenant cname?" unless Account.where(cname: args.tenant_cname).first
    AccountElevator.switch!(args.tenant_cname)
    puts "Importing historical views for #{args.tenant_cname}" 
    
  end

  desc 'import historical counter downloads'
  task :import_downloads, [:tenant_cname] => :environment do |_cmd, args|
    raise ArgumentError, 'A tenant cname is required: `rake counter_metrics:import_downloads[tenant_cname]`' if args.tenant_cname.blank?
    raise ArgumentError, "Tenant not found: #{args.tenant_cname}. Are you sure this is the correct tenant cname?" unless Account.where(cname: args.tenant_cname).first
    AccountElevator.switch!(args.tenant_cname)
    puts "Importing historical downloads for #{args.tenant_cname}" 
    
  end
end
