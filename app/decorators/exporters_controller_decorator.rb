# Ensures @exporter is loaded for the entry_table action.
# In your routes, entry_table uses :exporter_id, while other member actions use :id.
# Without this, @exporter is nil and the DataTables AJAX /entry_table.json 500s.

module Bulkrax
  module ExportersControllerDecorator
    def self.prepended(base)
      base.before_action :ensure_exporter_loaded_for_entry_table, only: [:entry_table]
    end

    private

    def ensure_exporter_loaded_for_entry_table
      @exporter ||= Bulkrax::Exporter.find_by(id: params[:exporter_id] || params[:id])
      head :not_found unless @exporter
    end
  end
end
