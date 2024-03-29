# frozen_string_literal: true

Bulkrax.setup do |config|
  # Add local parsers
  # config.parsers += [
  #   { name: 'MODS - My Local MODS parser', class_name: 'Bulkrax::ModsXmlParser', partial: 'mods_fields' },
  # ]

  # WorkType to use as the default if none is specified in the import
  # Default is the first returned by Hyrax.config.curation_concerns
  # config.default_work_type = GenericWork

  # Path to store pending imports
  config.import_path = ENV["SCHOLAR_BULKRAX_IMPORT_PATH"]

  # Path to store exports before download
  config.export_path = ENV["SCHOLAR_BULKRAX_EXPORT_PATH"]

  # Server name for oai request header
  # config.server_name = 'my_server@name.com'

  # NOTE: Creating Collections using the collection_field_mapping will no longer be supported as of Bulkrax version 3.0.
  #       Please configure Bulkrax to use related_parents_field_mapping and related_children_field_mapping instead.
  # Field_mapping for establishing a collection relationship (FROM work TO collection)
  # This value IS NOT used for OAI, so setting the OAI parser here will have no effect
  # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
  # The default value for CSV is collection
  # Add/replace parsers, for example:
  # config.collection_field_mapping['Bulkrax::RdfEntry'] = 'http://opaquenamespace.org/ns/set'

  # Field mappings
  # Create a completely new set of mappings by replacing the whole set as follows
  #   config.field_mappings = {
  #     "Bulkrax::OaiDcParser" => { **individual field mappings go here*** }
  #   }

  config.field_mappings = {
    "Bulkrax::CsvParser" => {
      "advisor" => { from: ["advisor"], parsed: true, split: '\|' },
      "alternate_title" => { from: ["alternate_title"], parsed: true, split: '\|' },
      "college" => { from: ["college"] },
      "committee_member" => { from: ["committee_member"], parsed: true, split: '\|' },
      "creator" => { from: ["creator"], split: '\|' },
      "date_created" => { from: ["date_created"] },
      "degree" => { from: ["degree"] },
      "department" => { from: ["department"] },
      "description" => { from: ["description"] },
      "doi" => { from: ["doi"] },
      "etd_publisher" => { from: ["etd_publisher"] },
      "genre" => { from: ["genre"] },
      "issn" => { from: ["issn"], split: '\|' },
      "journal_title" => { from: ["journal_title"], split: '\|' },
      "language" => { from: ["language"], split: '\|' },
      "license" => { from: ["license"], split: '\|', parsed: true },
      "note" => { from: ["note"] },
      "publisher" => { from: ["publisher"] },
      "related_url" => { from: ["related_url"], split: '\|' },
      "required_software" => { from: ["required_software"] },
      "subject" => { from: ["subject"], split: '\|' },
      "geo_subject" => { from: ["geo_subject"], split: '\|' },
      "time_period" => { from: ["time_period"], split: '\|' },
      "title" => { from: ["title"], parsed: true, split: '\|' }
    }
  }

  config.field_mappings['Bulkrax::BagitParser'] = {
    "advisor" => { from: ["advisor"], parsed: true, split: '\|' },
    "alternate_title" => { from: ["alternate_title"], parsed: true, split: '\|' },
    "college" => { from: ["college"] },
    "committee_member" => { from: ["committee_member"], parsed: true, split: '\|' },
    "creator" => { from: ["creator"], split: '\|' },
    "date_created" => { from: ["date_created"] },
    "degree" => { from: ["degree"] },
    "department" => { from: ["department"] },
    "description" => { from: ["description"] },
    "doi" => { from: ["doi"] },
    "etd_publisher" => { from: ["etd_publisher"] },
    "genre" => { from: ["genre"] },
    "issn" => { from: ["issn"], split: '\|' },
    "journal_title" => { from: ["journal_title"], split: '\|' },
    "language" => { from: ["language"], split: '\|' },
    "license" => { from: ["license"], split: '\|', parsed: true },
    "note" => { from: ["note"] },
    "publisher" => { from: ["publisher"] },
    "related_url" => { from: ["related_url"], split: '\|' },
    "required_software" => { from: ["required_software"] },
    "subject" => { from: ["subject"], split: '\|' },
    "geo_subject" => { from: ["geo_subject"], split: '\|' },
    "time_period" => { from: ["time_period"], split: '\|' },
    "title" => { from: ["title"], parsed: true, split: '\|' }
  }

  # Add to, or change existing mappings as follows
  #   e.g. to exclude date
  #   config.field_mappings["Bulkrax::OaiDcParser"]["date"] = { from: ["date"], excluded: true  }
  #
  #   e.g. to import parent-child relationships
  config.field_mappings['Bulkrax::CsvParser']['parents'] = { from: ['parents'], related_parents_field_mapping: true }
  config.field_mappings['Bulkrax::CsvParser']['children'] = { from: ['children'], related_children_field_mapping: true }

  config.field_mappings['Bulkrax::BagitParser']['parents'] = { from: ['parents'], related_parents_field_mapping: true }
  config.field_mappings['Bulkrax::BagitParser']['children'] = { from: ['children'], related_children_field_mapping: true }
  #   (For more info on importing relationships, see Bulkrax Wiki: https://github.com/samvera-labs/bulkrax/wiki/Configuring-Bulkrax#parent-child-relationship-field-mappings)
  #
  # #   e.g. to add the required source_identifier field
  #   #   config.field_mappings["Bulkrax::CsvParser"]["source_id"] = { from: ["old_source_id"], source_identifier: true  }
  # If you want Bulkrax to fill in source_identifiers for you, see below

  # To duplicate a set of mappings from one parser to another
  #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
  #   config.field_mappings["Bulkrax::OaiDcParser"].each {|key,value| config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value }

  # Should Bulkrax make up source identifiers for you? This allow round tripping
  # and download errored entries to still work, but does mean if you upload the
  # same source record in two different files you WILL get duplicates.
  # It is given two aruguments, self at the time of call and the index of the reocrd
  #    config.fill_in_blank_source_identifiers = ->(parser, index) { "b-#{parser.importer.id}-#{index}"}
  # or use a uuid
  config.fill_in_blank_source_identifiers = ->(_parser, _index) { SecureRandom.uuid }
  #    config.fill_in_blank_source_identifiers = ->(obj, index) { "Scholar-#{obj.importerexporter.id}-#{index}" }

  # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
  # config.reserved_properties += ['my_field']

  # List of Questioning Authority properties that are controlled via YAML files in
  # the config/authorities/ directory. For example, the :rights_statement property
  # is controlled by the active terms in config/authorities/rights_statements.yml
  # Defaults: 'rights_statement' and 'license'
  # config.qa_controlled_properties += ['my_field']
end

# Sidebar for hyrax 3+ support
Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions" if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
