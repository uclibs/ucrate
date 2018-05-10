# frozen_string_literal: true

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  # Which translations are available for the user to select
  # @return [Hash<String,String>] locale abbreviations as keys and flags as values
  def available_translations
    {
      'en' => 'English',
      'es' => 'Español',
      'zh' => '中文'
    }
  end
end
