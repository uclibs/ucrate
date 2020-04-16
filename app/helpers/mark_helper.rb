# frozen_string_literal: true

module MarkHelper
  def catalog(input_text)
    value = input_text.to_s
    filter_chars = params[:q].to_s.split(' ')
    if !filter_chars.empty?
      filter_chars.each do |char|
        value = value.gsub!(/#{char}/i, '<mark>' + char.capitalize + '</mark>').to_s
        value = input_text.to_s if value.empty?
      end
    else
      value = value.to_s
    end

    value.html_safe
  end
end
