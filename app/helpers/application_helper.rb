# frozen_string_literal: true

module ApplicationHelper
  include ::HyraxHelper
  include Hyrax::OverrideHelperBehavior
  include GroupNavigationHelper
  include SharedSearchHelper

  # rubocop:disable Rails/OutputSafety
  def index_filter(options = {})
    options[:value][0].truncate(300).to_s.html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
