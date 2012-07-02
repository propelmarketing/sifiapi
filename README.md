# SifiApi

Offers a simple way to interact with the Simpli.fi API via Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'sifiapi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sifiapi

## Basic Usage

    APPKEY = "your_app_key"
    connection = SifiApi::Connection.new(APPKEY)

    user = connection.user(user_key, :include => "companies,clients")

    # see available resources
    puts user.resources

    # get the company and it's client
    company = user.companies.first
    client = company.clients.first

## Create, Update, and Destroy Resource

    campaign = client.create(:campaign)
    campaign.update({ :name => "Testing via API!" })
    campaign.delete

## Capturing Errors

    # Capture for all resources
    class SifiApi::Resource
      rescue_from SifiApi::NotFound, :with => proc{|e| puts "Not found!" }
      rescue_from SifiApi::UnprocessableEntity, :with => proc{|e| puts "Failed to update!" }
    end

    # Capture per an individual resource
    class SifiApi::User
      rescue_from SifiApi::NotFound, :with => proc{|e| puts "User: Not found!" }
    end

    # Locally capture an error
    begin
      campaign.update({ :bid => "invalid" })
    rescue SifiApi::UnprocessableEntity => exception
      puts exception.message
    end

## Attaching Files to updates

    keywords = campaign.keywords
    csv = Tempfile.new(['keywords', 'csv'])
    csv.print("keyword one,2.50\nkeyword two,2.25\nkeyword three,5.00")
    csv.rewind
    keywords.update(:csv => csv)

## Downloading Files

    keywords = campaign.keywords
    csv = keywords.download
    csv.is_a?(Tempfile) # true

## Ruby Versions

This has been tested against Ruby 1.9.2.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
