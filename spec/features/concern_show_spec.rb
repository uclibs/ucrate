# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe 'search display fields', type: :feature, js: true do
  let(:user) { create(:user) }
  let!(:collection_type) { create(:collection_type, id: 1) }

  context 'with a work with all the meta' do
    let!(:jills_work) do
      create(:public_article,
             id: "ABCDEFG123",
             head: [],
             tail: [],
             depositor: "chuck@example.com",
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
             license: ["https://creativecommons.org/licenses/by/4.0/"],
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

    before do
      visit "/concern/articles/" + jills_work.id
    end

    it 'displays the correct fields' do
      assert_selector('dl.article dt:nth-child(1)', text: 'Creator')
      assert_selector('dl.article dt:nth-child(3)', text: 'College')
      assert_selector('dl.article dt:nth-child(5)', text: 'Department')
      assert_selector('dl.article dt:nth-child(7)', text: 'Subject')
      assert_selector('dl.article dt:nth-child(9)', text: 'Publisher')
      assert_selector('dl.article dt:nth-child(11)', text: 'Language')
      assert_selector('dl.article dt:nth-child(13)', text: 'Date Created')
      assert_selector('dl.article dt:nth-child(15)', text: 'Related url')
      assert_selector('dl.article dt:nth-child(17)', text: 'Alternate title')
      assert_selector('dl.article dt:nth-child(19)', text: 'Journal title')
      assert_selector('dl.article dt:nth-child(21)', text: 'Issn')
      assert_selector('dl.article dt:nth-child(23)', text: 'Time period')
      assert_selector('dl.article dt:nth-child(25)', text: 'Required software')
      assert_selector('dl.article dt:nth-child(27)', text: 'Note')
      assert_selector('dl.article dt:nth-child(29)', text: 'Geographic Subject')
      assert_selector('dl.article dt:nth-child(31)', text: 'License')
      assert_selector('dl.article dt:nth-child(33)', text: 'Rights')
    end
  end
end
