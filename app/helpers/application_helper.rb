# frozen_string_literal: true

module ApplicationHelper
  include ::HyraxHelper
  include Hyrax::OverrideHelperBehavior
  include GroupNavigationHelper
  include SharedSearchHelper

  def index_filter options={}
    "#{ options[:value][0].truncate(300)}".html_safe
  end

end
