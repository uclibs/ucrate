# frozen_string_literal: true

# Generated by hyrax:models
class Collection < ActiveFedora::Base
  include ::Hyrax::CollectionBehavior
  include ::Hyrax::Collections::Featured
  # You can replace these metadata if they're not suitable
  include BasicCollectionMetadata
  self.indexer = Hyrax::CollectionWithBasicMetadataIndexer

  property :license, predicate: ::RDF::Vocab::DC.rights, multiple: false

  def self.multiple?(field)
    if [:title, :description, :license].include? field.to_sym
      false
    else
      super
    end
  end

  def multiple?(field)
    CollectionForm.multiple? field
  end
end
