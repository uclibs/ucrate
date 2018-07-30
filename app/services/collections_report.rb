# frozen_string_literal: true
class CollectionsReport < Report
  def self.report_objects
    Collection.all
  end

  def self.fields(collection = Collection.new)
    [
      { id: collection.id },
      { title: collection.title },
      { depositor: collection.depositor },
      { edit_users: collection.edit_users.join(" ") },
      { works: collection_members(collection).join(" ") }
    ]
  end

  def self.collection_members(collection)
    return [] if collection.id.nil?
    query_solr(collection).map(&:id)
  end

  def self.query_solr(object)
    ActiveFedora::SolrService.query("member_of_collection_ids_ssim:#{object.id}", rows: 1_000_000)
  end
end
