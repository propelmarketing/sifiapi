require 'tempfile'

class SifiApi::Resource
  include ActiveSupport::Rescuable

  def initialize(json, connection, user_key)
    @json = json
    @connection = connection
    @user_key = user_key
    @cache = {}
    @paging = false
  end

  def raw_json
    @json
  end

  def update(params={})
    params = { resource_name.singularize => params }
    execute_with_rescue do
      response = @connection.put(@user_key, self.resource, params)
      if response && response.body
        @json = response.body[resource_name].first
      end
    end
    self
  end

  def create(resource, params={})
    params = { resource => params }
    execute_with_rescue do
      resource_name = resource.to_s.pluralize
      response = @connection.post(@user_key, self.resource + "/#{resource_name}", params)
      if response && response.body
        handle_response
        record = response.body[resource_name].first
        SifiApi.const_get(resource.to_s.classify).new(record, @connection, @user_key)
      end
    end
  end

  def find(resource, id)
    execute_with_rescue do
      resource_name = resource.to_s.pluralize
      record = @connection.get(@user_key, self.resource + "/#{resource_name}").body[resource_name].select{|x| x["id"].to_i == id.to_i }.first
      record ? SifiApi.const_get(resource.to_s.classify).new(record, @connection, @user_key) : []
    end
  end

  def delete
    execute_with_rescue do
      @connection.delete(@user_key, self.resource)
    end
  end

  def reload(params={})
    execute_with_rescue do
      response = @connection.get(@user_key, self.resource, params)
      if response && response.body
        @json = response.body[resource_name].first
        @cache = {}
      end
    end
    self
  end

  def self.get_via_uri(connection, user_key, uri='', params={})
    a = []
    response = connection.get(user_key, uri, params)
    if response && response.body
      response.body[resource_name].each do |record|
        resource = self.new(record, connection, user_key)
        a << resource
      end
      SifiApi::ResourceCollection.new(resource_name, a, response.body["paging"], connection, user_key)
    end
  end

  def method_missing(sym, *args, &block)
    if @json.respond_to?(sym)
      @json.send(sym, *args, &block)
    elsif val = (@json["resources"] || []).select { |r| r[sym.to_s] }.first
      return get_resource(sym.to_s, val[sym.to_s], *args)
    elsif @json.has_key?(sym.to_s)
      return @json[sym.to_s]
    elsif val = (@json["actions"] || []).select { |a| a[sym.to_s] }.first
      return do_action(val[sym.to_s])
    else
      super(sym, *args, &block)
    end
  end

  def do_action(action)
    execute_with_rescue do
      response = @connection.send(action["method"].downcase, @user_key, action["href"])
      if response && response.status == 200
        if response[:content_type].include?("application/json")
          @json = response.body[resource_name].first
          return self
        elsif ["text/csv", "application/zip"].include?(response[:content_type])
          filename = response.headers[:content_disposition].match(/filename="(.+)"/)[1]
          file = Tempfile.new(filename)
          file.write(response.body)
          file.rewind
          return file
        end
      end
      response
    end
  end

  def resource_name
    self.class.name.split("::").last.underscore.pluralize.downcase
  end

  def self.resource_name
    self.name.split("::").last.underscore.pluralize.downcase
  end

  def to_s
    @json.inspect
  end

  protected

  def get_resource(name, uri, params={})
    execute_with_rescue do
      force = params.delete(:ignore_cache)
      if @cache[name] && @cache[name][:params] == params && force != true
        @cache[name][:records]
      else
        @cache[name] = { :params => params }
        if params == {} && @json[name]
          records = []
          @json[name].each do |record|
            records << SifiApi.const_get(name.classify).new(record, @connection, @user_key)
          end
          records = SifiApi::ResourceCollection.new(name, records, nil, @connection, @user_key)
        else
          records = SifiApi.const_get(name.classify).get_via_uri(@connection, @user_key, uri, params)
        end
        @cache[name][:records] = records
      end
    end
  end

  def execute_with_rescue(&block)
    yield
  rescue Exception => exception
    rescue_with_handler(exception) || raise
  end

end
