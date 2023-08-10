# frozen_string_literal:true

module Sushi
  ##
  # Raised when the parameter we are given does not match our expectations; e.g. we can't convert
  # the text value to a Date.
  class InvalidParameterValue < StandardError
  end

  def self.coerce_to_date(value)
    value.to_date
  rescue StandardError
    begin
      # We can't parse the original date, so lets attempt to coerce a "YYYY-MM" string (year-month).
      # If it fails, we'll raise an exception on garbage input.
      year, month, = value.split('-')

      # We want to set the date to the 1st of the month.
      Date.new(year.to_i, month.to_i, 1)
    rescue StandardError
      raise Sushi::InvalidParameterValue, "Unable to convert \"#{value}\" to a date."
    end
  end
end