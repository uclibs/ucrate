# frozen_string_literal: true
require 'rails_helper'

describe 'DOI Validation', type: :feature, js: true do
  let(:user) { FactoryBot.create(:user) }
  let(:invalid_doi) { 'http://dx.doi.org/doi:10.5072/FK29P3386P' }
  let(:valid_doi) { 'doi:10.5072/FK29P3386P' }
  let(:empty_value) { '' }
  let(:error_message) { 'DOIs are required to begin with "doi:"' }
  let(:success_message) { 'Congratulations, a valid DOI was detected!' }

  context 'when submitting a DOI' do
    before do
      sign_in user
      begin
        visit new_hyrax_generic_work_path
      rescue Capybara::Poltergeist::JavascriptError
      end
      click_link "DOI"
    end
    context 'with the proper radio button checked' do
      before do
        choose('no-doi')
      end

      context 'and the input\'s value is empty' do
        it 'does nothing' do
          within '.set-doi' do
            fill_in 'generic_work_existing_identifier', with: empty_value
          end
          expect(page).not_to have_content(error_message)
          expect(page).not_to have_content(success_message)
        end
      end
      context 'and the DOI is invalid' do
        it 'presents an error message to the user' do
          within '.set-doi' do
            fill_in 'generic_work_existing_identifier', with: invalid_doi
          end

          expect(page).to have_content(error_message)
          expect(page).not_to have_content(success_message)
        end
      end

      context 'and the DOI is valid' do
        it 'presents a success message to the user' do
          within '.set-doi' do
            fill_in 'generic_work_existing_identifier', with: valid_doi
          end

          expect(page).not_to have_content(error_message)
          expect(page).to have_content(success_message)
        end
      end
    end
    context 'with the proper radio button unchecked' do
      before do
        choose('mint-doi')
      end
      context 'and the DOI is invalid' do
        it 'does nothing' do
          within '.set-doi' do
            fill_in 'generic_work_existing_identifier', with: invalid_doi
          end
          expect(page).not_to have_content(error_message)
          expect(page).not_to have_content(success_message)
        end
      end

      context 'and the DOI is valid' do
        it 'does nothing' do
          within '.set-doi' do
            fill_in 'generic_work_existing_identifier', with: valid_doi
          end
          expect(page).not_to have_content(error_message)
          expect(page).not_to have_content(success_message)
        end
      end
    end
  end
end
