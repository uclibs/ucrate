module CollectionExportHelper
  def collection_title(id)
    Collection.find(id).title.first
  rescue ActiveFedora::ObjectNotFoundError
    "the collection doesn't exist"
  end
end
