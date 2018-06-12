# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Scanning for virus during file upload', :js, :workflow do
  let(:user) { create(:user) }
  let!(:ability) { ::Ability.new(user) }

  before do
    # Grant the user access to deposit into an admin set.
    create(:permission_template_access,
           :deposit,
           permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
           agent_type: 'user',
           agent_id: user.user_key)
    # stub out characterization. Travis doesn't have fits installed, and it's not relevant to the test.
    allow(CharacterizeJob).to receive(:perform_later)
    allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(true)
  end

  shared_examples 'infected submission' do
    it 'warns user about virus' do # rubocop:disable RSpec/ExampleLength
      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      within('span#addfiles') do
        attach_file("files[]", fixture_path + "/world.png", visible: false)
      end
      expect(page).to have_content('Virus detected in file')
    end
  end

  context "to a new work" do
    before do
      sign_in user
      visit new_hyrax_generic_work_path
    end
    it_behaves_like 'infected submission'
  end

  context "to an existing work" do
    let(:work) { FactoryBot.build(:work, user: user, title: ['My Infected Work']) }
    let(:file_set) { FactoryBot.create(:file_set, user: user, title: ['ABC123xyz']) }

    before do
      sign_in user
      work.ordered_members << file_set
      work.read_groups = []
      work.save!
      visit edit_hyrax_generic_work_path(work)
    end
    it_behaves_like 'infected submission'
  end
end
