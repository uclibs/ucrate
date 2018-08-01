# frozen_string_literal: true
require 'rails_helper'
require 'rake'

describe 'embargo_release' do # rubocop:disable RSpec/DescribeClass
  before do
    load_rake_environment [Rails.root.join('lib', 'tasks', 'embargo_release.rake')]
  end

  context 'by default' do
    it 'expires any leases and embargoes from today' do
      expect(ExpirationService).to receive(:call).with(Time.zone.today)
      run_task('embargo_release')
    end
  end

  context 'with a specific date' do
    it 'expires any leases and embargoes from today' do
      expect(ExpirationService).to receive(:call).with(Date.parse('12/12/20'))
      run_task('embargo_release', '12/12/20')
    end
  end
end
