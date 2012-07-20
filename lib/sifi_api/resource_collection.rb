class SifiApi::ResourceCollection

  def initialize(resource_name, resources, paging, connection, user_key)
    @resource_name = resource_name
    @resources = resources
    @paging = paging || {}
    @connection = connection
    @user_key = user_key
  end

  def has_paging?
    @paging.has_key?("page")
  end

  def has_next_page?
    @paging.has_key?("next")
  end

  def has_previous_page?
    @paging.has_key?("previous")
  end

  def next_page
    if has_next_page?
      response = @connection.get(@user_key, @paging["next"])
      if response && response.body
        @resources = response.body[@resource_name].map do |record|
          SifiApi.const_get(@resource_name.classify).new(record, @connection, @user_key)
        end
        @paging = response.body["paging"]
      end
    end
  end

  def previous_page
    if has_previous_page?
      response = @connection.get(@user_key, @paging["previous"])
      if response && response.body
        @resources = response.body[@resource_name].map do |record|
          SifiApi.const_get(@resource_name.classify).new(record, @connection, @user_key)
        end
        @paging = response.body["paging"]
      end
    end
  end

  def current_page
    has_paging? ? @paging["page"] : nil
  end

  def page_size
    has_paging? ? @paging["size"] : nil
  end

  def total_pages
    has_paging? ? (@paging["total"].to_f/@paging["size"]).ceil : nil
  end

  def total_records
    has_paging? ? @paging["total"] : nil
  end

  def method_missing(sym, *args, &block)
    if @resources.respond_to?(sym)
      @resources.send(sym, *args, &block)
    end
  end

  def to_s
    @resources.inspect
  end

end
