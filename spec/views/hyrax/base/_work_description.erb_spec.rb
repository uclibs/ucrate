# frozen_string_literal: true
require 'spec_helper'
require 'rails_helper'

describe "render description in a partial" do
  Presenter = Struct.new(:description)
  it "displays note with new lines" do
    presenter = Presenter.new(["Paragraph One\r\n\r\nParagraph Two"])
    render partial: "hyrax/base/work_description.erb", locals: { presenter: presenter }
    expect(rendered).to include("<p>Paragraph One</p>")
    expect(rendered).to include("<p>Paragraph Two</p>")
  end
end
