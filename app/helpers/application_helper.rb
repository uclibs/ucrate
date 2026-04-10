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
    if record.respond_to?(:title_or_label) && record.title_or_label.present?
      label = normalized_thumbnail_label(record.title_or_label)
      return label if label.present?
    end

    if record.respond_to?(:title) && record.title.present?
      value = record.title.is_a?(Array) ? record.title.first : record.title
      label = normalized_thumbnail_label(value)
      return label if label.present?
    end

    if record.respond_to?(:to_s) && record.to_s.present?
      label = normalized_thumbnail_label(record.to_s)
      return label if label.present?
    end

    nil
  end

  def thumbnail_type_for(record)
    return record.human_readable_type.to_s.strip if record.respond_to?(:human_readable_type) && record.human_readable_type.present?

    nil
  end

  def normalized_thumbnail_label(value)
    label = value.to_s.strip
    return nil if label.blank? || label.casecmp('null').zero?

    label
  end
end
