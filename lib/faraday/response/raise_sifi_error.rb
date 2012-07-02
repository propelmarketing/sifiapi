module Faraday
  class Response::RaiseSifiError < Response::Middleware
    def on_complete(response)
      case response[:status].to_i
      when 400
        raise SifiApi::BadRequest, error_message(response)
      when 401
        raise SifiApi::Unauthorized, error_message(response)
      when 403
        raise SifiApi::Forbidden, error_message(response)
      when 404
        raise SifiApi::NotFound, error_message(response)
      when 406
        raise SifiApi::NotAcceptable, error_message(response)
      when 422
        raise SifiApi::UnprocessableEntity, error_message(response)
      when 500
        raise SifiApi::InternalServerError, error_message(response)
      when 501
        raise SifiApi::NotImplemented, error_message(response)
      when 502
        raise SifiApi::BadGateway, error_message(response)
      when 503
        raise SifiApi::ServiceUnavailable, error_message(response)
      end
    end

    def error_message(response)
      msg = "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{response[:status]}"
      if errors = response[:body] && response[:body]["errors"]
        msg << "\n"
        msg << errors.join("\n")
      end
      msg
    end
  end
end
