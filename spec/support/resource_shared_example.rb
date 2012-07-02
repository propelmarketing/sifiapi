require 'spec_helper'

class SifiApi::FakeResource < SifiApi::Resource
end

shared_examples_for 'SifiApi::Resource' do |resource|
  before(:all) do
    @connection = connection
    @user_key = "user_key"
    @resource = resource.new(fake_resource, @connection, @user_key)
  end

  it "should expose the raw json" do
    @resource.raw_json.should == fake_resource
  end

  it "should expose properties of the json as methods of the class" do
    @resource.name.should == fake_resource["name"]
  end

  it "should support hash methods run directly against the raw json" do
    @resource.keys.should == fake_resource.keys
  end

  it "should call action if method is an action" do
    action = fake_resource["actions"].first["do_something"]
    begin
      @connection.should_receive(action["method"].downcase.to_sym).with(@user_key, action["href"])
    rescue SifiApi::NotFound => e
    end
    @resource.do_something
  end

  it "should load the resource if the method is a resource" do
    resource = fake_resource["resources"].first
    begin
      @connection.should_receive(:get).with(@user_key, resource["fake_resources"], {})
    rescue SifiApi::NotFound => e
    end
    @resource.fake_resources
  end

  it "should pass along params passed to a resource method call" do
    resource = fake_resource["resources"].first
    params = { :include => "testing" }
    begin
      @connection.should_receive(:get).with(@user_key, resource["fake_resources"], params)
    rescue SifiApi::NotFound => e
    end
    @resource.fake_resources(params)
  end

  it "should not pass along the 'ignore_cache' param to a resource method call" do
    resource = fake_resource["resources"].first
    params = { :include => "testing" }
    begin
      @connection.should_receive(:get).with(@user_key, resource["fake_resources"], params)
    rescue SifiApi::NotFound => e
    end
    @resource.fake_resources(params.merge!(:ignore_cache => true))
  end

  it "should provide a method to update the resource" do
    params = { :name => "Plain Resource" }
    begin
      @connection.should_receive(:put).with(@user_key, fake_resource["resource"], { @resource.resource_name.singularize => params})
    rescue SifiApi::NotFound => e
    end
    @resource.update(params)
  end

  it "should provide a method to create a nested resource" do
    params = { :name => "Nested Resource" }
    begin
      @connection.should_receive(:post).with(@user_key, "#{fake_resource["resource"]}/fake_resources", { "fake_resource" => params})
    rescue SifiApi::NotFound => e
    end
    @resource.create("fake_resource", params)
  end

  it "should provide a method to delete a resource" do
    begin
      @connection.should_receive(:delete).with(@user_key, fake_resource["resource"])
    rescue SifiApi::NotFound => e
    end
    @resource.delete
  end

  it "should provide a method to reload a resource" do
    begin
      @connection.should_receive(:get).with(@user_key, fake_resource["resource"], {})
    rescue SifiApi::NotFound => e
    end
    @resource.reload
  end

end
