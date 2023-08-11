# frozen_string_literal:true

# counter compliant format for the Server Status Report is found here: https://countermetrics.stoplight.io/docs/counter-sushi-api/f0dd30f814944-server-status
module Sushi
  class StatusReport
    attr_reader :account, :created
    # initializes the begin & end dates
    include Sushi::DateCoercion

    def initialize(params = {}, created: Time.zone.now, account:)
      @created = created
      @account = account
    end

    def status_report
      [
        {
          "Description" => "COUNTER Usage Reports for #{account.cname} platform.",
          "Service_Active" => true, # this info will likely come from the same place as the alerts come from
          "Registry_Record" => "",
          "Alerts" => [
            {
              "Date_Time" => "2016-08-02T12:54:05Z", # date and time of alert (this is the same format as "created")
              "Alert" => "Service will be unavailable Sunday midnight." # need to find out where these come from
            }
          ]
        }
      ]
    end
  end
end