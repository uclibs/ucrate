# frozen_string_literal: true

class RssQueryHandler
  def self.run_solr_query(row_amount = Rails.configuration.rss_feed_rows)
    ActiveFedora::SolrService.query('-has_model_ssim:Collection AND -has_model_ssim:FileSet AND visibility_ssi:open',
                                    rows: row_amount,
                                    sort: 'system_create_dtsi desc')
  end
end
