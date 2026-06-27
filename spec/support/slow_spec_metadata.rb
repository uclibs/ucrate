# frozen_string_literal: true

# Examples tagged :slow need Fedora, Solr, and/or a browser (see docs/modernization/TESTING.md).
# Run locally with: bin/rspec-fast  (excludes :slow)
# CircleCI runs the full suite (no filter).

SLOW_SPEC_FILE_PATTERNS = [
  %r{spec/features/},
  %r{spec/forms/hyrax/},
  %r{spec/indexers/},
  %r{spec/jobs/},
  %r{spec/mailers/embargo_mailer_spec\.rb\z},
  %r{spec/models/(article|dataset|document|etd|generic_work|image|medium|student_work)_spec\.rb\z},
  %r{spec/models/concerns/hyrax/collections/featured_spec\.rb\z},
  %r{spec/controllers/common_objects_controller_spec\.rb\z},
  %r{spec/controllers/concerns/scholar/work_controller_behavior_spec\.rb\z},
  %r{spec/controllers/hyrax/batch_uploads_controller_spec\.rb\z},
  %r{spec/controllers/hyrax/datasets_controller_spec\.rb\z},
  %r{spec/controllers/hyrax/depositors_controller_spec\.rb\z},
  %r{spec/controllers/hyrax/file_sets_controller_spec\.rb\z},
  %r{spec/controllers/hyrax/generic_works_controller_spec\.rb\z},
  %r{spec/services/expiration_service_spec\.rb\z},
  %r{spec/services/hyrax/fixity_check_failure_service_spec\.rb\z},
  %r{spec/services/hyrax/change_content_depositor_service_spec\.rb\z},
  %r{spec/services/hyrax/custom_stat_importer_spec\.rb\z},
  %r{spec/services/work_metadata_attribute_mapper_spec\.rb\z},
  %r{spec/services/collections_report_spec\.rb\z},
  %r{spec/services/hyrax/collection_types/permissions_service_spec\.rb\z},
  %r{spec/views/_toolbar\.html\.erb_spec\.rb\z},
  %r{spec/views/hyrax/base/_form_progress\.html\.erb_spec\.rb\z},
  %r{spec/views/hyrax/base/_form_visibility_component\.html\.erb_spec\.rb\z},
  %r{spec/views/hyrax/base/_relationships\.html\.erb_spec\.rb\z},
  %r{spec/views/hyrax/base/show\.html\.erb_spec\.rb\z},
  %r{spec/views/hyrax/dashboard/collections/edit\.html\.erb_spec\.rb\z},
  %r{spec/actors/hyrax/actors/mint_doi_actor_spec\.rb\z},
  %r{spec/controllers/collection_exports_controller_spec\.rb\z},
  %r{spec/helpers/change_manager/change_manager_helper_spec\.rb\z},
  %r{spec/jobs/attach_files_to_work_job_spec\.rb\z},
  %r{spec/jobs/proxy_edit_removal_job_spec\.rb\z},
  %r{spec/models/ability_spec\.rb\z},
  %r{spec/models/collection_spec\.rb\z},
  %r{spec/models/work_and_file_index_spec\.rb\z},
  %r{spec/services/collection_metadata_csv_factory_spec\.rb\z},
  %r{spec/services/hyrax/user_stat_adder_spec\.rb\z},
  %r{spec/services/work_loader_spec\.rb\z},
  %r{spec/views/catalog/_index_header_list_collection\.html\.erb_spec\.rb\z},
  %r{spec/views/hyrax/my/_collection_action_menu\.html\.erb_spec\.rb\z}
].freeze

RSpec.configure do |config|
  config.define_derived_metadata(type: :feature) { |metadata| metadata[:slow] = true }

  config.define_derived_metadata(clean_repo: true) { |metadata| metadata[:slow] = true }
  config.define_derived_metadata(:clean_repo) { |metadata| metadata[:slow] = true }

  config.define_derived_metadata(js: true) { |metadata| metadata[:slow] = true }

  combined_pattern = Regexp.union(SLOW_SPEC_FILE_PATTERNS)
  config.define_derived_metadata(file_path: combined_pattern) { |metadata| metadata[:slow] = true }
end
