# frozen_string_literal: true
require 'rails_helper'

shared_examples 'submission form with form#fileupload' do |work_class|
  let(:work_type) { work_class.name.underscore }
  let(:work) { create("#{work_type}_with_one_file".to_sym, title: ["Magnificent splendor"], description: ["My description"], source: ["The Internet"], based_near: ["USA"], user: user) }
  let(:user) { create(:user) }
  let(:work_path) { "/concern/#{work_type}s/#{work.id}" }

  before do
    sign_in user
    visit work_path
  end

  it "has metadata" do
    expect(page).to have_selector 'h2', text: 'Magnificent splendor'

    # Displays FileSets already attached to this work
    within '.related-files' do
      expect(page).to have_selector '.attribute-filename', text: 'A Contained FileSet'
    end
  end
end

shared_examples 'submission form without form#fileupload' do |work_class|
  let(:work) { create(:public_generic_work, title: ["Magnificent splendor"], description: ["My description"], source: ["The Internet"]) }
  let(:work_type) { work_class.name.underscore }
  let(:work_path) { "/concern/#{work_type}s/#{work.id}" }
  before do
    visit work_path
  end

  it "has metadata" do
    expect(page).to have_selector 'h2', text: 'Magnificent splendor'

    # Doesn't have the upload form for uploading more files
    expect(page).not_to have_selector "form#fileupload"
  end

  it "has some social media buttons" do
    page.should have_css('div.resp-sharing-button.resp-sharing-button--twitter.resp-sharing-button--small')
  end
end

shared_examples 'show work without files' do |work_class|
  let(:work_type) { work_class.name.underscore }
  let(:work) { create(:public_generic_work, title: ["Magnificent splendor"], description: ["My description"], source: ["The Internet"], user: user) }
  let(:user) { create(:user) }
  let(:work_path) { "/concern/#{work_type}s/#{work.id}" }

  before do
    sign_in user
    visit work_path
  end

  it 'displays clear warning', js: true do
    page.current_window.resize_to(5000, 5000)
    page.save_screenshot('screen.png')
    expect(page).to have_css('div.alert.alert-warning', text: 'This Generic Work has no files associated with it. (If you just created this Generic Work, it may take a few minutes for the files to display. Try refreshing the page again.) Otherwise, click edit to add more files.')
  end
end

describe "display a work" do
  context "as the work owner" do
    it_behaves_like "submission form with form#fileupload", GenericWork
  end

  context "as a user who is not logged in" do
    it_behaves_like 'submission form without form#fileupload', GenericWork
  end

  context "display a work without files" do
    it_behaves_like "show work without files", GenericWork
  end
end
