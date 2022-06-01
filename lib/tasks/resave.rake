
# frozen_string_literal: true
namespace 'scholar' do
  desc 'Resaves works'
  task resave: :environment do
    # NOTE: In order to see progress in the logs, you must have logging at :info or above
    WorksResave.work_resave
  end
end
