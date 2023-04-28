# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
module Hyrax
  # Generated controller for PaperOrReport
  class PaperOrReportsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PaperOrReport

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PaperOrReportPresenter
  end
end
