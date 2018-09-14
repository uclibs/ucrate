# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe EmbargoMailer do
  describe 'embargo_notify rake task' do
    let(:user) { FactoryBot.create(:user) }
    let(:work) { FactoryBot.create(:embargoed_generic_work, user: user, embargo_release_date: embargo_date) }

    before do
      described_class.deliveries = []
      load File.expand_path("../../../lib/tasks/embargo_notify.rake", __FILE__)
      Rake::Task.define_task(:environment)
      work
      Rake::Task['embargo_notify'].execute
    end

    shared_examples 'sends the email' do
      it "sends the EmbargoMailer.notify email" do
        expect(described_class.deliveries.length).to be >= 1
      end
    end

    context "an embargoed work expiring in 30 days" do
      let(:embargo_date) { Time.zone.today + 30 }
      it_behaves_like 'sends the email'
    end

    context "an embargoed work expiring in 14 days" do
      let(:embargo_date) { Time.zone.today + 14 }
      it_behaves_like 'sends the email'
    end

    context "an embargoed work expiring in 1 day" do
      let(:embargo_date) { Time.zone.today + 1 }
      it_behaves_like 'sends the email'
    end
  end

  describe 'class methods' do
    describe 'notify should' do
      it 'return a mail object with proper to and from' do
        expect(described_class.notify('user1@example.com', 'my test work', 5).to).to include('user1@example.com')
        expect(described_class.notify('user1@example.com', 'my test work', 5).to).to include('scholar@uc.edu')
        expect(described_class.notify('user1@example.com', 'my test work', 5).from).to include('scholar@uc.edu')
      end
    end
  end
end
