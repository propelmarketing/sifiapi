module Faraday
  class Response::ParseJson < Faraday::Middleware
    dependency 'multi_json'

    def call(env)
      @app.call(env).on_complete do
        if env[:response_headers]["content-type"].include?("application/json")
          env[:body] = convert_to_json(env[:body])
        end
      end
    end

    protected

    def convert_to_json(body)
      case body.strip
      when ''
        nil
      when 'true'
        true
      when 'false'
        false
      else
        begin
          ::MultiJson.decode(body)
        rescue Exception => exception
          raise SifiApi::InvalidJson
        end
      end
    end
  end
end
