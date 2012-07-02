$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require 'sifi_api'

require 'support/resource_shared_example'

RSpec.configure do |config|

  def connection
    SifiApi::Connection.new("app_key")
  end

  def fake_resource
    {
      "resource" => "https://app.simpli.fi/api/fake_resources/1",
      "id" => 1,
      "name" => "Fake Resource 1",
      "actions" => [
        { "do_something" => { "method" => "GET", "href" => "https://app.simpli.fi/api/fake_resources/1/do_something" } }
      ],
      "resources" => [
        { "fake_resources" => "https://app.simpli.fi/api/fake_resources/1/fake_resources" }
      ]
    }
  end

end
