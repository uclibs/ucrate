# frozen_string_literal: true

require Hyrax::Engine.root.join('app/forms/hyrax/forms/collection_form.rb')
module Hyrax
  module Forms
    class CollectionForm
      self.terms = [:title, :creator, :description, :license, :thumbnail_id, :representative_id, :visibility]

      self.required_fields = [:title, :creator, :description, :license]

      def self.model_attributes(_)
        attrs = super
        attrs[:title] = Array(attrs[:title]) if attrs[:title]
        attrs[:description] = Array(attrs[:description]) if attrs[:description]
        attrs
      end

      # Terms that appear above the accordion
      def primary_terms
        [:title, :creator, :description, :license]
      end

      # Terms that appear within the accordion
      def secondary_terms
        []
      end

      def title
        @attributes['title'].first || ''
      end

      def description
        @attributes['description'].first || ''
      end
    end
  end
end
