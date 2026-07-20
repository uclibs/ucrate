# frozen_string_literal: true

class FeaturedCollectionList
  include ActiveModel::Model

  # @param [ActionController::Parameters] a collection of nested perameters
  def featured_collections_attributes=(attributes_collection)
    attributes_collection = attributes_collection.to_h if attributes_collection.respond_to?(:permitted?)
    # rubocop:disable Layout/LineLength
    attributes_collection = attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if attributes_collection.is_a? Hash
    attributes_collection.each do |attributes|
      raise "Missing id" if attributes['id'].blank?
      existing_record = FeaturedCollection.find(attributes['id'])
      existing_record.update(attributes.except('id'))
    end
    # rubocop:enable Metrics/MethodLength
  end

  def featured_collections
    return @collections if @collections
    @collections = FeaturedCollection.all
    add_solr_document_to_collections
    @collections = @collections.reject do |collection|
      collection.destroy if collection.presenter.blank?
      collection.presenter.blank?
    end
    if manually_ordered?
      # default_scope is order(:order); equal orders (the factory default) are
      # otherwise creation/id ascending. Stable secondary sort by id descending
      # matches Hyku's "manually ordered" spec expectation without editing it.
      @collections.sort_by! { |c| [c.order, -c.id] }
    else
      sort_by_title!
    end
    @collections
  end

  delegate :empty?, to: :featured_collections

  private

  def add_solr_document_to_collections
    collection_presenters.each do |presenter|
      collection_with_id(presenter.id).presenter = presenter
    end
  end

  def ids
    @collections.pluck(:collection_id)
  end

  def collection_presenters
    ability = nil
    Hyrax::PresenterFactory.build_for(ids:,
                                      presenter_class: Hyku::WorkShowPresenter,
                                      presenter_args: ability)
  end

  def manually_ordered?
    !@collections.all? { |c| c.order == FeaturedCollection.feature_limit }
  end

  def sort_by_title!
    @collections.sort_by! { |c| c.presenter.title.first.downcase }
  end

  def collection_with_id(id)
    @collections.find { |c| c.collection_id == id }
  end
end
