require 'csv'

namespace :workflow do
  desc 'Update workflows'
  task update: :environment do
    # excluded_accounts = ["qa-2.commons-archive.org", "qa-3.commons-archive.org", "qa-12.commons-archive.org", "search-test-nd.commons-archive.org", "make-tenant.commons-archive.org", "delete-me.commons-archive.org", "delete-me-2.commons-archive.org", "nic4.commons-archive.org", "nic5.commons-archive.org", "delete-me-4.commons-archive.org", "catmango.commons-archive.org", "delete-me-when-done.commons-archive.org", "search.commons-archive.org"]
    excluded_accounts = ["search.hykucommons.org"] # production
    output_file_path = "/app/samvera/hyrax-webapp/output.csv"

    CSV.open(output_file_path, 'w') do |csv|
      csv << ["Account Info", "Error Message", "PUTS"]

      Account.find_each do |account|
        next if excluded_accounts.include?(account.cname)

        begin
          AccountElevator.switch!(account.cname)
          account_cname = account.cname
          csv << [account_cname]

          begin
            admin_sets = AdminSet.all
          rescue RSolr::Error::ConnectionRefused => e
            csv << ["#{admin_set.id}", "Connection refused error for Account: #{account.cname} & #{e.message}"]

            excluded_accounts << account.cname
            next # Skip to the next account if there is a connection error
          end

          admin_sets.each do |admin_set|
            # next if admin_set.permission_template&.source_id == 'admin_set/default'
            begin
              admin_set_active_workflow = admin_set.active_workflow
              admin_set_permission_template = admin_set.permission_template
              admin_set_permission_template_active_workflow = admin_set_permission_template.active_workflow

              if admin_set_permission_template_active_workflow.present? &&
                admin_set_permission_template_active_workflow.name == 'hyku_commons_mediated_deposit'

                csv << [nil,"#{admin_set.id}","#{admin_set_permission_template_active_workflow&.name} & #{admin_set_permission_template_active_workflow&.id}",nil]

                default_workflow = Sipity::Workflow.find_by(name: 'one_step_mediated_deposit')
                if default_workflow.present?
                  # activate the new workflow that is default
                  Sipity::Workflow.activate!(permission_template: default_workflow.permission_template, workflow_id: default_workflow.id, workflow_name: default_workflow.name)
                  csv << ["#{account.cname}", "#{admin_set}", "#{admin_set.id}", "#{admin_set_active_workflow}", "#{admin_set_active_workflow.id}", "#{admin_set_permission_template}", "#{admin_set_permission_template.id}", "#{admin_set_permission_template_active_workflow}", "#{admin_set_permission_template.available_workflows}"]
                else
                  csv << ["#{admin_set.id}", "default_workflow.present? == false for #{admin_set.id}"]
                end
              else
                csv << ["#{admin_set.id}", "admin_set_permission_template_active_workflow.present? && admin_set_permission_template_active_workflow.name == 'hyku_commons_mediated_deposit' == false",]
              end
            rescue Sipity::Workflow::NoActiveWorkflowError => e
              csv << ["#{admin_set.id}", "Sipity::Workflow::NoActiveWorkflowError & #{e.message}"]
            end
          rescue RSolr::Error::ConnectionRefused, Faraday::ConnectionFailed, Apartment::TenantNotFound => e
            csv << ["#{admin_set.id}", "RSolr::Error::ConnectionRefused, Faraday::ConnectionFailed, Apartment::TenantNotFound: #{account.cname} & #{e.message}"]

            excluded_accounts << account.cname
            next # Skip to the next account if there is an error
          end
        end
      end
    end
  end
end
