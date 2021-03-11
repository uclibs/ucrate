# frozen_string_literal: true

module WorksHelper
  def form_tabs_for(form:)
    super
    %w[metadata doi files relationships]
  end
end
