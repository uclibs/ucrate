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
    [title_or_label_value(record), title_value(record), to_s_value(record)]
      .map { |value| normalized_thumbnail_label(value) }
      .find(&:present?)
  end

  def thumbnail_type_for(record)
    return record.human_readable_type.to_s.strip if record.respond_to?(:human_readable_type) && record.human_readable_type.present?

    nil
  end

  def normalized_thumbnail_label(value)
    value = extract_first_label_value(value)
    label = value.to_s.strip
    return nil if label.blank? || label.casecmp('null').zero?

    label
  end

  def title_or_label_value(record)
    return unless record.respond_to?(:title_or_label)

    record.title_or_label
  end

  def title_value(record)
    return unless record.respond_to?(:title) && record.title.present?

    record.title.is_a?(Array) ? record.title.first : record.title
  end

  def to_s_value(record)
    return unless record.respond_to?(:to_s)

    record.to_s
  end

  def extract_first_label_value(value)
    return value.first if value.respond_to?(:first) && !value.is_a?(String)

    value
  end
end
