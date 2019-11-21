# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Concerns API", clean_repo: true do
  it_behaves_like 'concern calls', "articles"
  it_behaves_like 'concern calls', "images"
  it_behaves_like 'concern calls', "documents"
  it_behaves_like 'concern calls', "datasets"
  it_behaves_like 'concern calls', "media"
  it_behaves_like 'concern calls', "etds"
  it_behaves_like 'concern calls', "student_works"
  it_behaves_like 'concern calls', "generic_works"
end
