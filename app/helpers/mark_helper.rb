# frozen_string_literal: true

module MarkHelper
  def catalog(input_text)
    value = input_text.to_s

    # Ignore if the value is a hyperlink
    unless value.include? "a href"
      # Split the search params
      search_params = params[:q].to_s.split(' ')
      # Split each catalog item/text
      all_text = input_text.to_s.split(' ')
      count = -1
      if !search_params.empty?
        all_text.each do |each_text|
          count += 1
          text_downcase = each_text.to_s.downcase
          search_params.each do |char|
            search_param = char.to_s.downcase
            # Check if the catalog item/text has the search param
            next unless text_downcase.include?(search_param)
            # Replace the catalog item/text with <mark> tag
            text_downcase = each_text.gsub!(each_text, '<mark>' + each_text + '</mark>').to_s
            all_text[count] = if text_downcase.empty?
                                each_text.to_s
                              else
                                text_downcase
                              end
          end
        end
        # join the splitted catalog item/text with space
        value = all_text.join(" ")
      else
        value = value.to_s
      end
    end
    sanitize value, tags: ['mark', 'span', 'a']
  end
end
