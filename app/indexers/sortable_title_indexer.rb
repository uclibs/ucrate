# frozen_string_literal: true

module SortableTitleIndexer
  private

  def sortable_title(title)
    return '' if title.nil?
    cleaned_title = title.sub(/^\s+/i, "") # remove leading spaces
    cleaned_title.gsub!(/[^\w\s]/, "") # remove punctuation; preserve spaces and A-z 0-9
    cleaned_title.gsub!(/\s{2,}/, " ") # remove multiple spaces
    cleaned_title.sub!(/^(a |an |the )/i, "") # remove leading english articles
    cleaned_title.upcase! # upcase everything
    add_leading_zeros_to cleaned_title
  end

  def add_leading_zeros_to(title)
    leading_number = title.match(/^\d+/)
    return title if leading_number.nil?
    title.sub(/^\d+/, leading_number[0].rjust(20, "0"))
  end
end
