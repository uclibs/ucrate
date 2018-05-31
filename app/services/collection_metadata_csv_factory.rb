# frozen_string_literal: true

class CollectionMetadataCsvFactory
  attr_reader :collection_id

  def initialize(collection_id)
    @collection_id = collection_id
  end

  def create_csv
    CSV.open(csv_location, "w", col_sep: "\t") do |csv|
      csv << keys_for_member_objects_metadata

      member_objects_metadata.each do |object|
        csv << keys_for_member_objects_metadata.collect do |key|
          value = object[key]
          format_field_for value
        end
      end
    end

    csv_location
  end

  private

    def member_objects_metadata
      collection = Collection.find collection_id
      @member_objects_metadata ||= collection.member_objects.collect do |object|
        WorkMetadataAttributeMapper.new(object).object_attributes
      end
    end

    def csv_location
      @csv_location ||= Rails.root.join(
        "tmp", "#{collection_id}.#{Time.now.to_i}.csv"
      )
    end

    def keys_for_member_objects_metadata
      @keys_for_member_objects_metadata ||= member_objects_metadata.collect(&:keys).flatten.uniq
    end

    def format_field_for(value)
      if value.is_a? String
        value.gsub(/\r\n/, "|")
      elsif value.blank?
        nil
      else
        value.join("|").gsub(/\r\n/, "|")
      end
    end
end
