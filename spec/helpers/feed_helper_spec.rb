# frozen_string_literal: true

require 'rails_helper'

describe FeedHelper do
  describe '#url_for_work' do
    it 'returns the url for the work' do
      helper.url_for_work('p46543de7').should eq 'http://localhost:3000/show/p46543de7'
    end
  end
end
