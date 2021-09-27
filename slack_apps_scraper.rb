require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'kimurai'
end

require 'kimurai'

# SlackAppsScraper
class SlackAppsScraper < Kimurai::Base
  @name = 'slack_spider'
  @engine = :mechanize
  @start_urls = ['https://slack.com/apps/category/AtHC5Q7RUJ-daily-tools']

  def parse(response, url:, data: {})
    @base_uri = 'https://slack.com'
    response = browser.current_response
    response.css('ul.media_list li a').each do |app|
      href = app.attr('href')
      browser.visit(@base_uri + href)
      app_response = browser.current_response
      scraped_slack_apps(app_response)
    end
  end

  private

  def scraped_slack_apps(response)
    item = {}
    item[:name] = response.css('h2.p-app_info_title')&.text&.squish
    item[:description] = response.css('#panel_more_info div.p-app_description')&.text&.squish
    save_to "scraped_slack_apps.json", item, format: :pretty_json, position: false
  end
end

SlackAppsScraper.crawl!
