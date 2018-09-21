# frozen_string_literal: true

module Hyrax
  module Renderers
    class NoteRenderer < AttributeRenderer
      def attribute_value_to_html(value)
        if microdata_value_attributes(field).present?
          "<div#{html_attributes(microdata_value_attributes(field))}>#{li_value(value)}</div>"
        else
          li_value(value)
        end
      end

      def li_value(value)
        auto_link(ERB::Util.h(simple_format(value)))
      end
    end
  end
end
