# frozen_string_literal: true
require 'rails_helper'

feature 'DOIs', type: :feature, js: true do
  it_behaves_like 'doi request', GenericWork
  it_behaves_like 'doi request', Article
  it_behaves_like 'doi request', Image
  it_behaves_like 'doi request', Document
  it_behaves_like 'doi request', Dataset
  it_behaves_like 'doi request', Medium
  it_behaves_like 'doi request', Etd
  it_behaves_like 'doi request', StudentWork
end
