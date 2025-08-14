
module Bulkrax
  module ImportersControllerDecorator
    def self.prepended(base)
      base.before_action :ensure_importer_loaded_for_entry_table, only: [:entry_table]
    end
    private
    def ensure_importer_loaded_for_entry_table
      @importer ||= Bulkrax::Importer.find_by(id: params[:importer_id] || params[:id])
      head :not_found unless @importer
    end
  end
end
