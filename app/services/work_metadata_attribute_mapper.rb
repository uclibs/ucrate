# frozen_string_literal: true

class WorkMetadataAttributeMapper
  attr_reader :object_attributes

  def initialize(object)
    @object_attributes = gather_object_attributes(object)
  end

  private

    def gather_object_attributes(object)
      metadata = {}
      attributes(object).each do |attribute|
        metadata[attribute] = object.send(attribute.to_sym)
      end
      metadata
    end

    def attributes(object)
      map = (YAML.load_stream Rails.root.join("config", "metadata_export_map.yml").read).first
      map[object.class.to_s]
    end
end
