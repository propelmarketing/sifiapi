$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'sifiapi'
require 'date'
require 'tempfile'

# add application and user api keys
APPKEY  = 'APPLICATION_KEY_GOES_HERE'
USERKEY = 'USER_KEY_GOES_HERE'

api = SifiApi::Connection.new(APPKEY)
# can optionally pass a uri as the second param for the api end point (if you are testing against app-playground for instance)
#api = SifiApi::Connection.new(APPKEY, "https://app-playground.simpli.fi/api/")

# get the user and include the companies and clients in the result
user = api.user(USERKEY, :include => "companies,clients")

# grab the first company and the first companies client
company = user.companies.first
client = company.clients.first


# create a campaign from the client
search_campaign = client.create(:campaign)
search_campaign_settings = {
  :name => "Example Search Campaign via API",
  :campaign_type_id => 1,
  :recency_id => 1,
  :advertiser => "Example Advertiser",
  :start_date => Date.today.strftime("%Y-%m-%d"),
  :end_date => (Date.today + 30).strftime("%Y-%m-%d"),
  :bid_type_id => 1,
  :bid => 5.00,
  :daily_budget => 500.00,
  :dayparting_ids => [1,2],
  :browser_ids => [601,604],
  :device_ids => [701],
  :operating_system_ids => [801],
  :context_ids => [201,207],
  :geo_target_ids => [1,8180],
  :branded_data_ids => ['ECohortsDigital_26','ECohortsDigital_27'],
  :frequency_capping => { :how_many_times => 1, :hours => 1 },
  :campaign_goal => { :goal_type => "ctr", :goal_value => 0.05 },
  :impression_cap => 10000,
  :pacing => 75
}
# update the campaign with the desired settings
search_campaign.update(search_campaign_settings)

# reload the campaign and include the nested resources
puts search_campaign.reload(:include => "daypartings,browsers,devices,operating_systems,context_ids,branded_data").inspect


# setup an ad
html_ad_settings = {
  :name => "Example HTML Ad",
  :ad_file_type_id => 4,
  :ad_size_id => 3,
  :target_url => "http://www.simpli.fi/",
  :html => "<a href=\"{{clickTag}}\" target=\"_blank\">Simpli.fi</a>"
}
search_campaign.create(:ad, html_ad_settings)

puts search_campaign.ads.inspect

# upload some keywords for the campaign
keywords = search_campaign.keywords.first
keyword_csv = Tempfile.new(['keywords', 'csv'])
keyword_csv.print("keyword one,2.50\nkeyword two,2.25\nkeyword three,5.00")
keyword_csv.rewind
keywords.update(:csv => keyword_csv)

puts keywords.reload.inspect

# upload some domains
domains = search_campaign.domains.first
domain_csv = Tempfile.new(['domains', 'csv'])
domain_csv.print("http://simpli.fi/")
domain_csv.rewind
domains.update(:csv => domain_csv, :list_type => "whitelist")

puts domains.reload.inspect

# upload some ip ranges
ip_ranges = search_campaign.ip_ranges.first
ip_ranges_csv = Tempfile.new(['ip_ranges', 'csv'])
ip_ranges_csv.print("192.168.1.1,192.168.1.9\n192.168.2.1,192.168.2.9")
ip_ranges_csv.rewind
ip_ranges.update(:csv => ip_ranges_csv)

puts ip_ranges.reload.inspect

