# frozen_string_literal: true
class Report
  require 'csv'

  def self.report_location
    [Rails.root, 'vendor', report_title].join('/')
  end

  def self.create_report
    CSV.open(report_location, "w") do |csv|
      csv << report_header
      report_objects.each do |object|
        csv << report_row(object)
      end
    end
  end

  def self.report_title
    name.underscore + '.csv'
  end

  def self.report_header
    fields.collect do |field|
      field.keys[0]
    end
  end

  def self.report_row(object)
    fields(object).collect do |field|
      if field.values[0].is_a? ActiveTriples::Relation
        field.values[0].join("|").tr("\n", " ")
      else
        field.values.join("|").tr("\n", " ")
      end
    end
  end
end
