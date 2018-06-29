# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Browse catalog:", type: :feature, clean_repo: true do
  let!(:jills_work) do
    GenericWork.new do |work|
      work.title = ["Jill's Research"]
      (1..25).each do |i|
        work.subject << ["subject#{format('%02d', i)}"]
      end
      work.apply_depositor_metadata('jilluser')
      work.read_groups = ['public']
      work.save!
    end
  end

  let!(:jacks_work) do
    GenericWork.new do |work|
      work.title = ["Jack's Research"]
      work.subject = ['jacks_subject']
      work.apply_depositor_metadata('jackuser')
      work.read_groups = ['public']
      work.save!
    end
  end

  before do
    visit '/'
  end

  describe 'when not logged in' do
    it 'using facet pagination to browse by subject' do
      click_button "search-submit-header"

      expect(page).to have_content 'Search Results'
      expect(page).to have_content jills_work.title.first
      expect(page).to have_content jacks_work.title.first

      click_link "Subject"
      click_link "more Subjects »"
      within('.bottom') do
        click_link 'Next »'
      end

      within(".modal-body") do
        expect(page).not_to have_content 'subject05'
        expect(page).to have_content 'subject21'

        click_link 'subject21'
      end

      expect(page).to have_content jills_work.title.first
      expect(page).not_to have_content jacks_work.title.first

      # TODO:  After the _generic_work.html.erb view is finished
      #
      #      click_link jills_work.title.first
      #      expect(page).to     have_content "Download"
      #      expect(page).not_to have_content "Edit"
    end
  end
end
