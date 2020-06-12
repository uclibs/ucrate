require "rails_autolink/helpers"
require Hyrax::Engine.root.join('app/renderers/hyrax/renderers/attribute_renderer.rb')

module Hyrax
  module Renderers
    class AttributeRenderer
      # Draw the table row for the attribute
      def render
        markup = ''

        return markup if (values.blank? || array_of_empty_strings?(values)) && !options[:include_empty]
        markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
        Array(values).each do |value|
          markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
        end
        markup << %(</ul></td></tr>)
        markup.html_safe
      end

      # Draw the dl row for the attribute
      def render_dl_row
        markup = ''

        return markup if (values.blank? || array_of_empty_strings?(values)) && !options[:include_empty]
        markup << %(<dt>#{label}</dt>\n<dd><ul class='tabular'>)
        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
        Array(values).each do |value|
          markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
        end
        markup << %(</ul></dd>)
        markup.html_safe
      end

      private

      def array_of_empty_strings?(values)
        return true if values.is_a?(Array) && values.all?(&:empty?)
        false
      end
    end
  end
end
