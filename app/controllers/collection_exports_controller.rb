# frozen_string_literal: true

require 'stringio'

class CollectionExportsController < ApplicationController
  before_action :set_collection_export, only: [:show, :destroy]
  before_action :authenticate_user!

  with_themed_layout 'dashboard'

  # GET /collection_exports
  def index
    @tz = if cookies["timezone"]
            TZInfo::Timezone.get(cookies["timezone"])
          else
            TZInfo::Timezone.get("America/New_York")
          end

    @collection_exports = CollectionExport.all.order(created_at: :desc).select { |ce| can? :show, ce }
  end

  # POST /collection_exports
  def create
    if can? :show, Collection.find(collection_id)
      @collection_data = CollectionExport.create(
        export_file: new_collection_export_file.read,
        collection_id: collection_id,
        user: current_user.email
      )

      redirect_to collection_exports_url, notice: I18n.t("collection_export.create_confirmation")
    else
      render file: 'public/403.html', status: :forbidden
    end
  end

  def download
    set_collection_export
    if can? :show, @collection_export
      send_data @collection_export.export_file,
                filename: @collection_export.collection_id + ".tsv",
                type: 'application/octet-stream',
                disposition: 'attachment'
    else
      render file: 'public/403.html', status: :forbidden
    end
  end

  # DELETE /collection_exports/1
  def destroy
    if can? :destroy, @collection_export
      @collection_export.destroy

      respond_to do |format|
        format.html { redirect_to collection_exports_url, notice: I18n.t("collection_export.destroy_confirmation") }
      end
    else
      render file: 'public/403.html', status: :forbidden
    end
  end

  private

  def new_collection_export_file
    factory = CollectionMetadataCsvFactory.new(collection_id)
    factory.create_csv
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_collection_export
    @collection_export = CollectionExport.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def collection_id
    params.fetch(:collection_id)
  end

  def return_export_file_object(_id, _data)
    File
      .entries = Dir.entries(Rails.root.join('tmp'))
  end
end
