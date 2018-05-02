# frozen_string_literal: true

require Hyrax::Engine.root.join('app/presenters/hyrax/file_set_presenter.rb')
module Hyrax
  class FileSetPresenter
    include ModelProxy
    include PresentsAttributes
    include CharacterizationBehavior
    include WithEvents
    include DisplaysImage

    def sha1
      solr_document.sha1_checksum
    end
  end
end
