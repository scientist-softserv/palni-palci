# frozen_string_literal: true

# OVERRIDE: Hyrax hyrax-v3-5-0 so that the dashboard user graph updates correctly after new users are added

module Hyrax
  module Statistics
    module Users
      module OverTimeDecorator
        # OVERRIDE: Hyrax hyrax-v3-5-0
        def point(date_string)
          # convert the User::ActiveRecord_Relation to an array so that ".count" returns a number,
          # instead of a hash of { user_id: count }
          relation.where(query(date_string)).to_a.count
        end
      end
    end
  end
end

::Hyrax::Statistics::Users::OverTime.prepend(Hyrax::Statistics::Users::OverTimeDecorator)
