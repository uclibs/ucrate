# frozen_string_literal: true

require 'rails_helper'

describe 'RSS Feed' do
  let!(:pub_work_1) { create(:public_generic_work, title: ['Public Work One']) }
  let!(:pub_work_2) { create(:public_generic_work, title: ['Public Work Two']) }
  let!(:pub_work_3) { create(:public_generic_work, title: ['Public Work Three']) }
  let!(:priv_work)  { create(:private_generic_work, title: ['Private Work']) }
  let!(:collection) { create(:public_collection, title: ['Public Collection']) }

  before do
    visit '/feed.rss?size=2'
  end

  it 'returns the specified number of items' do
    expect(page).not_to have_content pub_work_1.title.first
    expect(page).to have_content pub_work_2.title.first
    expect(page).to have_content pub_work_3.title.first
  end

  it 'excludes private works' do
    expect(page).not_to have_content priv_work.title.first
  end

  it 'excludes collections' do
    expect(page).not_to have_content collection.title.first
  end
end
