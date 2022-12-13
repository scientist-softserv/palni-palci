# frozen_string_literal: true
module Hyrax
  class SearchBuilder < ::SearchBuilder
    self.default_processor_chain += [:show_works_or_works_that_contain_files]
  end
end