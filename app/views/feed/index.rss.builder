# frozen_string_literal: true

xml.instruct!
xml.rss version: '2.0' do
  xml.channel do
    xml.title t('hyrax.product_name')
    xml.description t('hyrax.description')
    xml.link Rails.configuration.application_root_url
    xml.language 'en'
    @works.each do |work|
      xml.item do
        xml.title work['title_tesim'].first
        xml.description work['description_tesim'].nil? ? '' : work['description_tesim'].first
        xml.link url_for_work(work['id'])
        xml.pubDate work['system_create_dtsi']
      end
    end
  end
end
