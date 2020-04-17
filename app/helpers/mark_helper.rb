# frozen_string_literal: true

module MarkHelper
  def catalog(input_text)
    value = input_text.to_s
    filter_chars = params[:q].to_s.split(' ')
    unless filter_chars.empty?
      value = value.to_s
    else
      filter_chars.each do |char|
        value = value.gsub!(/#{char}/i, '<mark>' + char + '</mark>').to_s
        value = input_text.to_s if value.empty?
      end
    end

    value.html_safe
  end
end
