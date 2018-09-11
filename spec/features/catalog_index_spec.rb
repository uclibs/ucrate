# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe 'search display fields', type: :feature, js: true do
  let(:user) { create(:user) }
  let!(:collection_type) { create(:collection_type, id: 1) }
  let!(:collection_type_2) { create(:collection_type, id: 2) }

  before do
    allow(User).to receive(:find_by_user_key).and_return(stub_model(User, twitter_handle: 'bob'))
    sign_in user
    jills_work.license = ["http://creativecommons.org/licenses/by/4.0/"]
    jills_work.save
    visit '/catalog'
  end

  context 'with works and collections' do
    let!(:jills_work) do
      create(:public_article,
             head: [],
             tail: [],
             depositor: "greenmcg@mail.uc.edu",
             date_uploaded: "2018-08-01 19:44:30",
             date_modified: "2018-08-01 19:44:30",
             title: ["Index Show Test Item"],
             proxy_depositor: nil,
             on_behalf_of: nil,
             arkivo_checksum: nil,
             owner: nil,
             alternate_title: ["Alternate Test Index Name"],
             geo_subject: ["Cincinnati, Ohio"],
             journal_title: ["Journal Title"],
             issn: ["000000"],
             time_period: ["The Future"],
             required_software: "MATLAB",
             college: "Engineering and Applied Science",
             department: "Digital Collections and Repositories",
             note: "Notes",
             label: nil,
             relative_path: nil,
             import_url: nil,
             resource_type: [],
             creator: ["Greenman, Charles"],
             contributor: [],
             description: ["Abstract."],
             keyword: [],
             license: ["http://creativecommons.org/licenses/by/4.0/"],
             rights_statement: ["http://rightsstatements.org/vocab/InC/1.0/"],
             publisher: ["0123456789"],
             date_created: ["2018-07-30"],
             subject: ["The Subject"],
             language: ["English"],
             identifier: [],
             based_near: [],
             related_url: ["http://dropbox.com/about.pdf"],
             bibliographic_citation: [],
             source: ["Journal Title"],
             representative_id: nil,
             thumbnail_id: nil,
             rendering_ids: [])
    end

    it 'performing a search' do
      within('#search-form-header') do
        fill_in('search-field-header', with: '')
        click_button('Go')
      end
      expect(page).to have_content('Search Results')
      expect(page).to have_content(jills_work.title.first)
    end

    it 'has the correct display facets' do
      page.current_window.resize_to(2000, 2000)
      page.save_screenshot('screenshot.png')
      expect(page).to have_selector('.dl-horizontal', text: "Type:")
      expect(page).to have_selector('.dl-horizontal', text: "Description/Abstract:")
      expect(page).to have_selector('.dl-horizontal', text: "Creator/Author:")
      expect(page).to have_selector('.dl-horizontal', text: "Submitter:")
      # Dates aren't showing in the test environment.
      skip "Dates aren't showing up in test environment."
      expect(page).to have_selector('.dl-horizontal', text: "Date Uploaded:")
      skip "Dates aren't showing up in test environment."
      expect(page).to have_selector('.dl-horizontal', text: "Date Modified:")
      skip "Dates aren't showing up in test environment."
      expect(page).to have_selector('.dl-horizontal', text: "Date Created:")
      expect(page).to have_selector('.dl-horizontal', text: "License:")
    end
  end
end
