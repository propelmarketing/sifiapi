module Faraday
  class Request::ConvertFileToUploadIO < Faraday::Middleware
    def call(env)
      if env[:body].is_a?(Hash)
        resource = env[:body].keys.first
        env[:body][resource].each do |key, value|
          if value.is_a?(File) || value.is_a?(Tempfile)
            env[:body][resource][key] = Faraday::UploadIO.new(value, mime_type(value.path), value.path)
          elsif value.is_a?(Hash) && (value['io'].is_a?(IO) || value['io'].is_a?(StringIO))
            env[:body][resource][key] = Faraday::UploadIO.new(value['io'], mime_type('.'+value['type']), '')
          end
        end
      end
      @app.call(env)
    end

    private

    def mime_type(path)
      case path
      when /\.jpe?g/i
        'image/jpeg'
      when /\.gif$/i
        'image/gif'
      when /\.png$/i
        'image/png'
      when /\.swf$/i
        'application/swf'
      when /\.csv$/i
        'text/csv'
      else
        'application/octet-stream'
      end
    end

  end
end
