# frozen_string_literal: true

class SortTitle
  def initialize(title)
    @title = title
  end

  def alphabetical
    title = @title.titlecase
    title = title.sub(/^An/, '').sub(/^A/, '').sub(/^The/, '')
    title.strip
  end
end
