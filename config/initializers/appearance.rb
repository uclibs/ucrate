# frozen_string_literal: true

if ActiveRecord::Base.connection.table_exists? :content_blocks
  appearance = Hyrax::Forms::Admin::Appearance.new(
    header_background_color: '#222',
    header_text_color: '#ffffff',
    link_color: '#e00122',
    footer_link_color: '#ffffff',
    primary_button_background_color: '#e00122'
  )
  appearance.update!
end
