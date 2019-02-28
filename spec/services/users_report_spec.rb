# frozen_string_literal: true
require 'rails_helper'

describe UsersReport do
  describe '#report_location' do
    it 'is vendor/users_report.csv' do
      expect(described_class.report_location).to eq("#{Rails.root}/vendor/users_report.csv")
    end
  end

  describe '#create_report' do
    let(:fake_users) { [
      FakeUser.new('id1', 'foo@bar.com', 'Foo Bar', 'Foo', 'Bar'),
      FakeUser.new('id1', 'foo@bar.com', 'Foo Bar', 'Foo', 'Bar'),
      FakeUser.new('id1', 'foo@bar.com', 'Foo Bar', 'Foo', 'Bar'),
      FakeUser.new('id1', 'foo@bar.com', 'Foo Bar', 'Foo', 'Bar')
    ] }

    before do
      User.stub(:all).and_return(fake_users)

      File.delete(described_class.report_location) if File.exist?(described_class.report_location)
    end

    it 'creates a report in the report_location' do
      described_class.create_report
      expect(File).to exist(described_class.report_location)
    end

    it 'creates a report one line longer than the number of objects reported on' do
      described_class.create_report
      expect(
        File.open(described_class.report_location).readlines.size
      ).to eq(fake_users.length + 1)
    end

    class FakeUser < Struct.new(:id, :email, :name, :first_name, :last_name)
    end
  end
end