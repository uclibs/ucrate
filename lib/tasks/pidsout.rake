
# frozen_string_literal: true
namespace 'scholar' do
  desc 'Output PIDS'
  task pidsout: :environment do
    PidsOut.pids_output
  end
end
