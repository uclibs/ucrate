# frozen_string_literal: true
module Hyrax::Collections
  module Featured
    extend ActiveSupport::Concern
    included do
      before_destroy :cleanup_featured_collections
      after_save :check_featureability
    end

    def cleanup_featured_collections
      FeaturedCollection.where(collection_id: id).destroy_all
    end

    def check_featureability
      return unless private?
      cleanup_featured_collections if featured?
    end

    def featured?
      return true if FeaturedCollection.find_by_collection_id(id)
      false
    end
  end
end
