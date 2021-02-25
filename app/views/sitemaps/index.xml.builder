# frozen_string_literal: true

xml.instruct! :xml, version: '1.0'
xml.tag! 'urlset', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                   'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
                   'xmlns:image' => 'http://www.google.com/schemas/sitemap-image/1.1',
                   'xmlns:video' => 'http://www.google.com/schemas/sitemap-video/1.1',
                   'xmlns:geo' => 'http://www.google.com/geo/schemas/sitemap/1.0',
                   'xmlns:news' => 'http://www.google.com/schemas/sitemap-news/0.9',
                   'xmlns:mobile' => 'http://www.google.com/schemas/sitemap-mobile/1.0',
                   'xmlns:pagemap' => 'http://www.google.com/schemas/sitemap-pagemap/1.0',
                   'xmlns:xhtml' => 'http://www.w3.org/1999/xhtml',
                   'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 ' \
         'http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd' do
  xml.url do
    xml.loc @root_url
    xml.changefreq "always"
    xml.priority 1.0
  end

  @static_pages.each do |url|
    xml.url do
      xml.loc url
      xml.changefreq "monthly"
      xml.priority 0.8
    end
  end

  @catalog_urls.each do |url|
    xml.url do
      xml.loc url
      xml.lastmod Time.zone.now.strftime "%Y-%d-%m"
      xml.changefreq "daily"
      xml.priority 1.0
    end
  end

  @resources.each do |work|
    xml.url do
      xml.loc work[:url]
      xml.lastmod work[:lastmod]
      xml.changefreq "weekly"
      xml.priority 0.8
    end
  end
end
