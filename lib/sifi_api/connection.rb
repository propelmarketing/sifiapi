require 'faraday/request/convert_file_to_upload_io'
require 'faraday/request/json_encode'
require 'faraday/response/raise_sifi_error'
require 'faraday/response/parse_json'

class SifiApi::Connection
  def initialize(app_key, site="https://app.simpli.fi/api/")
    @site = site
    @app_key = app_key
    @connection = Faraday::Connection.new(:url => site, :ssl => { :verify => false }) do |builder|
      builder.use Faraday::Request::ConvertFileToUploadIO
      builder.request  :multipart
      builder.use Faraday::Request::JsonEncode

      builder.use Faraday::Response::RaiseSifiError
      builder.use Faraday::Response::SifiParseJson

      builder.adapter Faraday.default_adapter
    end
  end

  def user(user_key, params={})
    SifiApi::User.get_via_uri(self, user_key, '', params).first
  end

  def get(user_key, route='', params={}, headers={})
    begin
      @connection.run_request(:get, @connection.build_url(route, params), nil, { "X-App-Key" => @app_key, "X-User-Key" => user_key }.merge(headers))
    rescue Faraday::Error::TimeoutError => e
      raise SifiApi::Timeout, "Timeout"
    end
  end

  def post(user_key, route='', body=nil, headers={})
    begin
      @connection.run_request(:post, route, body, { "X-App-Key" => @app_key, "X-User-Key" => user_key }.merge(headers))
    rescue Faraday::Error::TimeoutError => e
      raise SifiApi::Timeout, "Timeout"
    end
  end

  def put(user_key, route='', body=nil, headers={})
    begin
      @connection.run_request(:put, route, body, { "X-App-Key" => @app_key, "X-User-Key" => user_key }.merge(headers))
    rescue Faraday::Error::TimeoutError => e
      raise SifiApi::Timeout, "Timeout"
    end
  end

  def delete(user_key, route='', body=nil, headers={})
    begin
      response = @connection.run_request(:delete, route, body, { "X-App-Key" => @app_key, "X-User-Key" => user_key }.merge(headers))
      response[:status] == 204
    rescue Faraday::Error::TimeoutError => e
      raise SifiApi::Timeout, "Timeout"
    end
  end

end
