require 'rails_helper'

describe 'layouts/application' do
  it 'has a UCRATE page title' do
    render
    expect(rendered).to have_title 'UCRATE'
  end

  it 'has a UCRATE header' do
    render
    expect(rendered).to have_selector('h1', text: 'UCRATE')
  end

  context 'when there is a Devise success alert' do
    let(:notice) { double 'success notice' }
    it 'a success alert is displayed' do
      allow(view).to receive(:notice) { notice }
      render
      expect(rendered).to have_selector('p.alert-success', text: 'success notice')
    end
  end

  context 'when there is a Devise danger alert' do
    let(:notice) { double 'danger notice' }
    it 'a danger alert is displayed' do
      allow(view).to receive(:notice) { notice }
      render
      expect(rendered).to have_selector('p.alert-success', text: 'danger notice')
    end
  end
end
