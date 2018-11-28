# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyrax::CustomStatImporter do
  before do
    allow(Hyrax.config).to receive(:analytic_start_date) { dates[0] }

    allow(FileViewStat).to receive(:ga_statistics) do |_date, file|
      case file
      when bilbo_file_1
        bilbo_file_1_pageview_stats
      end
    end

    allow(FileDownloadStat).to receive(:ga_statistics) do |_date, file|
      case file
      when bilbo_file_1
        bilbo_file_1_download_stats
      end
    end

    allow(WorkViewStat).to receive(:ga_statistics) do |_date, work|
      case work
      when bilbo_work_1
        bilbo_work_1_pageview_stats
      end
    end
  end

  let(:bilbo) { create(:user, email: 'bilbo@example.com') }

  let!(:bilbo_file_1) do
    create(:file_set, id: 'xyzbilbo1', user: bilbo)
  end

  let!(:bilbo_work_1) do
    create(:work, id: 'xyzbilbowork1', user: bilbo)
  end

  let(:dates) do
    ldates = []
    4.downto(0) { |idx| ldates << (Time.zone.today - idx.day) }
    ldates
  end

  let(:date_strs) do
    ldate_strs = []
    dates.each { |date| ldate_strs << date.strftime("%Y%m%d") }
    ldate_strs
  end

  # This is what the data looks like that's returned from Google Analytics via the Legato gem.
  let(:bilbo_file_1_pageview_stats) do
    [
      SpecStatistic.new(date: date_strs[0], pageviews: 1),
      SpecStatistic.new(date: date_strs[1], pageviews: 2),
      SpecStatistic.new(date: date_strs[2], pageviews: 3),
      SpecStatistic.new(date: date_strs[3], pageviews: 4),
      SpecStatistic.new(date: date_strs[4], pageviews: 5)
    ]
  end

  let(:bilbo_work_1_pageview_stats) do
    [
      SpecStatistic.new(date: date_strs[0], pageviews: 1),
      SpecStatistic.new(date: date_strs[1], pageviews: 2),
      SpecStatistic.new(date: date_strs[2], pageviews: 3),
      SpecStatistic.new(date: date_strs[3], pageviews: 4),
      SpecStatistic.new(date: date_strs[4], pageviews: 5)
    ]
  end

  let(:bilbo_file_1_download_stats) do
    [
      SpecStatistic.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "bilbo1", date: date_strs[0], totalEvents: "2"),
      SpecStatistic.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "bilbo1", date: date_strs[1], totalEvents: "3"),
      SpecStatistic.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "bilbo1", date: date_strs[2], totalEvents: "5"),
      SpecStatistic.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "bilbo1", date: date_strs[3], totalEvents: "3"),
      SpecStatistic.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "bilbo1", date: date_strs[4], totalEvents: "7")
    ]
  end

  let(:work_index_object) do
    WorkAndFileIndex.create(
      object_id: bilbo_work_1.id,
      object_type: "work",
      user_email: bilbo.email
    )
  end

  let(:file_index_object) do
    WorkAndFileIndex.create(
      object_id: bilbo_file_1.id,
      object_type: "file",
      user_email: bilbo.email
    )
  end

  subject { described_class.new(work_index_object, delay_secs: 0, retries: 4) }

  context "works" do
    it "adds all data" do
      expect { subject.import }.to change { WorkViewStat.count }.by(4)
    end

    it "doesn't add duplicate data" do
      described_class.new(work_index_object, delay_secs: 0, retries: 4).import
      expect { subject.import }.not_to(change { WorkViewStat.count })
    end
  end

  context "files" do
    subject { described_class.new(file_index_object, delay_secs: 0, retries: 4) }

    it "adds all file view data" do
      expect { subject.import }.to change { FileViewStat.count }.by(4)
    end

    it "adds all file download data" do
      expect { subject.import }.to change { FileDownloadStat.count }.by(4)
    end

    it "doesn't add duplicate data" do
      described_class.new(file_index_object, delay_secs: 0, retries: 4).import
      expect { subject.import }.not_to(change { FileDownloadStat.count })
    end
  end

  it "sets index object date" do
    expect(work_index_object.stats_last_gathered).to be_nil
    subject.import
    expect(work_index_object.reload.stats_last_gathered).to be_between(Time.zone.today - 1.day, Time.zone.today + 1.day)
  end

  context "without a stats_last_gathered date" do
    it "initializes the appropriate date" do
      expect(subject.start_date).to eq(dates[0])
    end
  end

  context "with a stats_last_gathered date" do
    let(:work_index_object) do
      WorkAndFileIndex.create(
        object_id: bilbo_work_1.id,
        object_type: "work",
        user_email: bilbo.email,
        stats_last_gathered: dates[2]
      )
    end

    it "initializes the appropriate date" do
      expect(subject.start_date.strftime("%Y%m%d")).to eq(date_strs[2])
    end
  end
end
