# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embargo' do
  let(:user) { create(:user) }

  before do
    sign_in user
  end
  describe 'creating an embargoed object' do
    let(:future_date) { 5.days.from_now }
    let(:later_future_date) { 10.days.from_now }

    it 'can be created, displayed and updated', :clean_repo, :workflow do
      visit '/concern/generic_works/new'

      title_element = find_by_id("generic_work_title")
      title_element.set("Embargo test") # Add whitespace to test it getting removed

      college_element = find_by_id("generic_work_college")
      college_element.select("Business")

      select 'Attribution-ShareAlike 4.0 International', from: 'generic_work_license'

      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Program or Department', with: 'University Department')
      fill_in('Description', with: 'This is a description.')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element

      choose 'Embargo'
      fill_in 'generic_work_embargo_release_date', with: future_date
      select 'Private', from: 'Restricted to'
      select 'Open Access', from: 'then open it up to'
      click_button 'Save'

      # chosen embargo date is on the show page
      expect(page).to have_content(future_date.to_date.to_formatted_s(:standard))

      click_link 'Edit'
      click_link 'Embargo Management Page'

      expect(page).to have_content('This Generic Work is under embargo.')
      expect(page).to have_xpath("//input[@name='generic_work[embargo_release_date]' and @value='#{future_date.to_datetime.iso8601}']") # current embargo date is pre-populated in edit field

      fill_in 'until', with: later_future_date.to_s

      click_button 'Update Embargo'
      expect(page).to have_content(later_future_date.to_date.to_formatted_s(:standard))
    end
  end

  describe 'updating embargoed object' do
    let(:my_admin_set) do
      create(:admin_set,
             title: ['admin set with embargo range'],
             with_permission_template: { release_period: "6mos", with_active_workflow: true })
    end
    let(:default_admin_set) do
      create(:admin_set, id: AdminSet::DEFAULT_ID,
                         title: ["Default Admin Set"],
                         description: ["A description"],
                         with_permission_template: {})
    end
    let(:future_date) { 5.days.from_now }
    let(:later_future_date) { 10.days.from_now }
    let(:invalid_future_date) { 185.days.from_now } # More than 6 months
    let(:admin) { create(:admin) }
    let(:work) do
      create(:work, title: ['embargoed work1'],
                    embargo_release_date: future_date.to_datetime.iso8601,
                    admin_set_id: my_admin_set.id,
                    edit_users: [user])
    end

    it 'can be updated with a valid date', js: true do
      visit "/concern/generic_works/#{work.id}"

      click_link 'Edit'
      click_link 'Embargo Management Page'

      expect(page).to have_content('This Generic Work is under embargo.')
      expect(page).to have_xpath("//input[@name='generic_work[embargo_release_date]' and @value='#{future_date.to_datetime.iso8601}']") # current embargo date is pre-populated in edit field

      fill_in 'until', with: later_future_date.to_s

      click_button 'Update Embargo'
      expect(page).to have_content(later_future_date.to_date.to_formatted_s(:standard))
    end

    it 'cannot be updated with an invalid date' do
      visit "/concern/generic_works/#{work.id}"

      click_link 'Edit'
      click_link 'Embargo Management Page'

      expect(page).to have_content('This Generic Work is under embargo.')
      expect(page).to have_xpath("//input[@name='generic_work[embargo_release_date]' and @value='#{future_date.to_datetime.iso8601}']") # current embargo date is pre-populated in edit field

      fill_in 'until', with: invalid_future_date.to_s

      click_button 'Update Embargo'
      expect(page).to have_content('Release date specified does not match permission template release requirements for selected AdminSet.')
    end
  end
end
