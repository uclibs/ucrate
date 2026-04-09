# frozen_string_literal: true

module CatalogHelper
  def render_thumbnail_tag(document, image_options = {}, url_options = {})
    options = image_options.to_h.symbolize_keys
    options[:alt] = thumbnail_alt_text_for(document) if options[:alt].blank?

    super(document, options, url_options)
  end
end