# frozen_string_literal: true

namespace :scholar do
  desc 'Starts fixity check on all files'
  task fixity_check: :environment do
    ::Hyrax::RepositoryFixityCheckService.fixity_check_everything
  end
end
