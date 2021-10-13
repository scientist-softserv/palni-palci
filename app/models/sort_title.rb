# frozen_string_literal: true

class SortTitle
  def initialize(title)
    @title = title
  end

  def alphabetical
    title = @title.downcase
    title = title.sub(/^an/, '').sub(/^a/, '').sub(/^the/, '')
    title_elements = title.split(' ')
    new_title = []
    title_elements.each do |str|
      numbers = str.gsub(/[^\d]/, '')
      unless numbers.empty?
        zero_num = numbers.rjust(6, '0')
        str = str.gsub(numbers, zero_num)
      end
      new_title.push(str)
    end
    title = new_title.join(' ')
    title.strip
  end
end
