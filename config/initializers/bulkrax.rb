# frozen_string_literal: true

Bulkrax.setup do |config|
  # ----- Paths & host -----
  # Prefer ENV, but fall back to tmp/* so dev/test still work
  config.import_path = ENV.fetch("SCHOLAR_BULKRAX_IMPORT_PATH", Rails.root.join("tmp/bulkrax/imports").to_s)
  config.export_path = ENV.fetch("SCHOLAR_BULKRAX_EXPORT_PATH", Rails.root.join("tmp/bulkrax/exports").to_s)

  # Needed for building absolute URLs in exports/downloads
  config.server_name = ENV.fetch("SCHOLAR_BULKRAX_SERVER_NAME", "localhost:3000")

  # Ensure directories exist (v9 expects writable paths)
  [config.import_path, config.export_path].each do |p|
    FileUtils.mkdir_p(p) unless File.directory?(p)
  end

  # ----- Default work type (optional; keep your project’s default if set elsewhere)
  # config.default_work_type = GenericWork

  # ----- Field mappings -----
  # Tip: use regex for split so behavior is explicit across versions
  config.field_mappings = {
    "Bulkrax::CsvParser" => {
      "title"            => { from: ["title"], parsed: true, split: /\|/ },
      "creator"          => { from: ["creator"], split: /\|/ },
      "college"          => { from: ["college"] },
      "department"       => { from: ["department"] },
      "description"      => { from: ["description"] },
      "license"          => { from: ["license"], split: /\|/, parsed: true },
      "publisher"        => { from: ["publisher"] },
      "date_created"     => { from: ["date_created"] },
      "alternate_title"  => { from: ["alternate_title"], parsed: true, split: /\|/ },
      "subject"          => { from: ["subject"], split: /\|/ },
      "geo_subject"      => { from: ["geo_subject"], split: /\|/ },
      "time_period"      => { from: ["time_period"], split: /\|/ },
      "language"         => { from: ["language"], split: /\|/ },
      "required_software"=> { from: ["required_software"] },
      "note"             => { from: ["note"] },
      "related_url"      => { from: ["related_url"], split: /\|/ },
      "advisor"          => { from: ["advisor"], parsed: true, split: /\|/ },
      "committee_member" => { from: ["committee_member"], parsed: true, split: /\|/ },
      "degree"           => { from: ["degree"] },
      "doi"              => { from: ["doi"] },
      "etd_publisher"    => { from: ["etd_publisher"] },
      "genre"            => { from: ["genre"] },
      "issn"             => { from: ["issn"], split: /\|/ },
      "journal_title"    => { from: ["journal_title"], split: /\|/ }
    }
  }

  config.field_mappings["Bulkrax::BagitParser"] = {
    "title"            => { from: ["title"], parsed: true, split: /\|/ },
    "creator"          => { from: ["creator"], split: /\|/ },
    "college"          => { from: ["college"] },
    "department"       => { from: ["department"] },
    "description"      => { from: ["description"] },
    "license"          => { from: ["license"], split: /\|/, parsed: true },
    "publisher"        => { from: ["publisher"] },
    "date_created"     => { from: ["date_created"] },
    "alternate_title"  => { from: ["alternate_title"], parsed: true, split: /\|/ },
    "subject"          => { from: ["subject"], split: /\|/ },
    "geo_subject"      => { from: ["geo_subject"], split: /\|/ },
    "time_period"      => { from: ["time_period"], split: /\|/ },
    "language"         => { from: ["language"], split: /\|/ },
    "required_software"=> { from: ["required_software"] },
    "note"             => { from: ["note"] },
    "related_url"      => { from: ["related_url"], split: /\|/ },
    "advisor"          => { from: ["advisor"], parsed: true, split: /\|/ },
    "committee_member" => { from: ["committee_member"], parsed: true, split: /\|/ },
    "degree"           => { from: ["degree"] },
    "doi"              => { from: ["doi"] },
    "etd_publisher"    => { from: ["etd_publisher"] },
    "genre"            => { from: ["genre"] },
    "issn"             => { from: ["issn"], split: /\|/ },
    "journal_title"    => { from: ["journal_title"], split: /\|/ }
  }

  # Relationships (v3+ approach — keep)
  config.field_mappings["Bulkrax::CsvParser"]["parents"]   = { from: ["parents"],  related_parents_field_mapping: true }
  config.field_mappings["Bulkrax::CsvParser"]["children"]  = { from: ["children"], related_children_field_mapping: true }
  config.field_mappings["Bulkrax::BagitParser"]["parents"] = { from: ["parents"],  related_parents_field_mapping: true }
  config.field_mappings["Bulkrax::BagitParser"]["children"]= { from: ["children"], related_children_field_mapping: true }

  # Fill in missing source identifiers (round‑tripping & error re‑downloads)
  config.fill_in_blank_source_identifiers = ->(_parser, _index) { SecureRandom.uuid }

  # QA/Reserved props (extend if you add controlled vocabs)
  # config.qa_controlled_properties += ['my_field']
  # config.reserved_properties      += ['my_field']
end

# Sidebar for Hyrax dashboard (works on Hyrax 3; guard for Hyrax 4+ if API changes)
if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
  Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions"
end
