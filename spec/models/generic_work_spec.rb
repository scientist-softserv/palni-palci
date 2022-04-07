# Generated via
#  `rails generate hyrax:work GenericWork`
require 'rails_helper'

RSpec.describe GenericWork do
  describe "metadata" do
    it { is_expected.to have_property(:bulkrax_identifier).with_predicate("https://hykucommons.org/terms/bulkrax_identifier") }
  end
end
