# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'uc:seed:samples' do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  before do
    Rake::Task['uc:seed:samples'].reenable
  end

  def run_task
    Rake::Task['uc:seed:samples'].invoke
  end

  it 'prints RESULT OK when the service skips' do
    allow(Uc::SampleSeedService).to receive(:call)
      .and_return(Uc::SampleSeedService::Result.new(status: :skipped))

    expect { run_task }.to output(/RESULT: OK — UC sample seeds already present \(skipped\)/).to_stdout
  end

  it 'prints RESULT OK and password guidance when the service creates samples' do
    allow(Uc::SampleSeedService).to receive(:call)
      .and_return(
        Uc::SampleSeedService::Result.new(
          status: :created,
          password_source: :initial_admin_password,
          created_count: 12
        )
      )

    expect { run_task }.to output(
      /RESULT: OK — UC sample seeds completed successfully[\s\S]*INITIAL_ADMIN_PASSWORD[\s\S]*Objects indexed: 12/
    ).to_stdout
  end

  it 'prints RESULT FAILED and re-raises when the service errors' do
    allow(Uc::SampleSeedService).to receive(:call)
      .and_raise(RuntimeError, 'UC sample seeds must not run in production or staging.')

    expect { run_task }.to output(/RESULT: FAILED — RuntimeError: UC sample seeds must not run/)
      .to_stdout
      .and raise_error(RuntimeError, /must not run in production/)
  end
end
