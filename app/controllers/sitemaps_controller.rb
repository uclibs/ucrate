# frozen_string_literal: true

class SitemapsController < ApplicationController
  def index
    work_types = Hyrax.config.registered_curation_concern_types.append('Collection')

    @root_url = Rails.application.config.application_root_url
    @catalog_urls = []
    @resources = []

    @static_pages = StaticController.instance_methods(false).map { |action| get_static_url action }
    @catalog_urls.append strip_locale_from_url search_catalog_url

    work_types.each do |work_type|
      @catalog_urls << retrieve_facet_urls(work_type)
      retrieve_works_from_solr work_type
    end

    @static_pages.map! { |page_url| strip_locale_from_url page_url }

    respond_to { |format| format.xml }
  end

  private

  def retrieve_works_from_solr(work_type)
    ActiveFedora::SolrService.query("has_model_ssim:#{work_type}", rows: 1_000_000).each do |work|
      next if work[:read_access_group_ssim] != ['public']
      work_metadata = {}
      work_metadata[:url] = sans_fedora_poly_url(work_type, work[:id])
      work_metadata[:lastmod] = work[:system_modified_dtsi].gsub(/T[0-9]{2}:[0-9]{2}:[0-9]{2}Z/, '')
      @resources << work_metadata
    end
  end

  def sans_fedora_poly_url(work_type, work_id)
    strip_locale_from_url(@root_url + "/#{url_prefix(work_type)}#{work_type.underscore.pluralize}/#{work_id}")
  end

  def url_prefix(work_type)
    return 'concern/' unless work_type == 'Collection'
    ''
  end

  def retrieve_facet_urls(work_type)
    strip_locale_from_url(@root_url + "/catalog?f[human_readable_type_sim][]=#{work_type}")
  end

  def strip_locale_from_url(url_with_locale)
    url_with_locale.gsub('?locale=en', '')
  end

  def get_static_url(action)
    send "#{action}_url"
  end
end
