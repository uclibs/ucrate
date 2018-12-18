# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyrax::UserStatAdder do
  it "resets the cache" do
    us = UserStat.create
    described_class.reset_user_stats
    expect { us.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  context "with data" do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }

    let(:work1) { create(:generic_work, user: user) }
    let(:work2) { create(:generic_work, user: user) }
    let(:work3) { create(:generic_work, user: another_user) }
    let(:file1) { create(:file_set, user: user) }
    let(:file2) { create(:file_set, user: user) }
    let(:file3) { create(:file_set, user: another_user) }

    before do
      FileViewStat.create(views: 2, file_id: file1.id, user_id: user.id)
      FileViewStat.create(views: 3, file_id: file1.id, user_id: user.id)

      FileDownloadStat.create(downloads: 11, file_id: file1.id, user_id: user.id)
      FileDownloadStat.create(downloads: 13, file_id: file1.id, user_id: user.id)

      FileViewStat.create(views: 5, file_id: file2.id, user_id: user.id)
      FileViewStat.create(views: 3, file_id: file2.id, user_id: user.id)

      FileDownloadStat.create(downloads: 18, file_id: file2.id, user_id: user.id)
      FileDownloadStat.create(downloads: 11, file_id: file2.id, user_id: user.id)

      FileViewStat.create(views: 19, file_id: file3.id, user_id: another_user.id)
      FileViewStat.create(views: 31, file_id: file3.id, user_id: another_user.id)

      FileDownloadStat.create(downloads: 21, file_id: file3.id, user_id: another_user.id)
      FileDownloadStat.create(downloads: 13, file_id: file3.id, user_id: another_user.id)

      WorkViewStat.create(work_views: 23, work_id: work1.id, user_id: user.id)
      WorkViewStat.create(work_views: 29, work_id: work1.id, user_id: user.id)
      WorkViewStat.create(work_views: 31, work_id: work1.id, user_id: user.id)

      WorkViewStat.create(work_views: 10, work_id: work2.id, user_id: user.id)
      WorkViewStat.create(work_views: 1, work_id: work2.id, user_id: user.id)
      WorkViewStat.create(work_views: 0, work_id: work2.id, user_id: user.id)

      WorkViewStat.create(work_views: 105, work_id: work3.id, user_id: another_user.id)
      WorkViewStat.create(work_views: 9, work_id: work3.id, user_id: another_user.id)
      WorkViewStat.create(work_views: 30, work_id: work3.id, user_id: another_user.id)

      WorkAndFileIndex.reset
    end

    it "totals the work view stats for a user" do
      described_class.reset_user_stats
      expect(UserStat.find_by_user_id(user.id).work_views).to eq(94)
      expect(UserStat.find_by_user_id(another_user.id).work_views).to eq(144)
    end

    it "totals the file download stats for a user" do
      described_class.reset_user_stats
      expect(UserStat.find_by_user_id(user.id).file_downloads).to eq(53)
      expect(UserStat.find_by_user_id(another_user.id).file_downloads).to eq(34)
    end

    it "totals the file view stats for a user" do
      described_class.reset_user_stats
      expect(UserStat.find_by_user_id(user.id).file_views).to eq(13)
      expect(UserStat.find_by_user_id(another_user.id).file_views).to eq(50)
    end
  end
end
