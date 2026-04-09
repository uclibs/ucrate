# frozen_string_literal: true

module ApplicationHelper
  def thumbnail_alt_text_for(record)
    label = thumbnail_label_for(record)
    type = thumbnail_type_for(record)

    return "#{type} thumbnail: #{label}" if type.present? && label.present?
    return "Thumbnail for #{label}" if label.present?
    return "#{type} thumbnail" if type.present?

    'Thumbnail'
  end

  private

  def thumbnail_label_for(record)
    return record.title_or_label.to_s.strip if record.respond_to?(:title_or_label) && record.title_or_label.present?

    if record.respond_to?(:title) && record.title.present?
      value = record.title.is_a?(Array) ? record.title.first : record.title
      return value.to_s.strip if value.present?
    end

    return record.to_s.strip if record.respond_to?(:to_s) && record.to_s.present?

    nil
  end

  def thumbnail_type_for(record)
    return record.human_readable_type.to_s.strip if record.respond_to?(:human_readable_type) && record.human_readable_type.present?

    nil
  end
end
