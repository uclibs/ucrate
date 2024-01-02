# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument
  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)

  # Added for All Work Types

  def alternate_title
    self[ActiveFedora.index_field_mapper.solr_name('alternate_title')]
  end

  def abstract
    self[ActiveFedora.index_field_mapper.solr_name('abstract')]
  end

  def advisor
    self[ActiveFedora.index_field_mapper.solr_name('advisor')]
  end

  def committee_member
    self[ActiveFedora.index_field_mapper.solr_name('committee_member')]
  end

  def required_software
    self[ActiveFedora.index_field_mapper.solr_name('required_software')]
  end

  def time_period
    self[ActiveFedora.index_field_mapper.solr_name('time_period')]
  end

  def note
    self[ActiveFedora.index_field_mapper.solr_name('note')]
  end

  # Added for Article Work Type

  def journal_title
    self[ActiveFedora.index_field_mapper.solr_name('journal_title')]
  end

  def issn
    self[ActiveFedora.index_field_mapper.solr_name('issn')]
  end

  # Added for StudentWork, Document, and Image work types

  def genre
    self[ActiveFedora.index_field_mapper.solr_name('genre')]
  end

  def geo_subject
    self[ActiveFedora.index_field_mapper.solr_name('geo_subject')]
  end

  def degree
    self[ActiveFedora.index_field_mapper.solr_name('degree')]
  end

  #  Complex metadata fields that we be implemented later.

  #  def doi
  #    self[ActiveFedora.index_field_mapper.solr_name('doi')]
  #  end

  def college
    self[ActiveFedora.index_field_mapper.solr_name('college')]
  end

  def department
    self[ActiveFedora.index_field_mapper.solr_name('department')]
  end

  def doi
    self[ActiveFedora.index_field_mapper.solr_name('doi')]
  end

  def etd_publisher
    self[ActiveFedora.index_field_mapper.solr_name('etd_publisher')]
  end
end
