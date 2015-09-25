#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('#representative-region').each do |rep|
    source = URI.join("http://www.pyithuhluttaw.gov.mm/", rep.at_css('a[href*="q=representative/"]/@href').text).to_s
    data = { 
      id: File.basename(source).tr('%',''),
      name: rep.css('.region-representative-title .field-content').text.tidy,
      party: rep.css('.region-representative-party .field-content').text.tidy,
      area: rep.css('.region-constituency').text.tidy,
      image: rep.css('.region-representative-photo img/@src').text,
      term: 1,
      source: source,
    }
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

Dir['cache/*.html'].each { |f| scrape_list(f) }
