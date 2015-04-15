require "spec_helper"

describe PrivatePubPlus do
  before(:each) do
    PrivatePubPlus.reset_config
  end

  it "defaults server to nil" do
    PrivatePubPlus.config[:server].should be_nil
  end

  it "defaults signature_expiration to nil" do
    PrivatePubPlus.config[:signature_expiration].should be_nil
  end

  it "defaults subscription timestamp to current time in milliseconds" do
    time = Time.now
    Time.stub!(:now).and_return(time)
    PrivatePubPlus.subscription[:timestamp].should eq((time.to_f * 1000).round)
  end

  it "loads a simple configuration file via load_config" do
    PrivatePubPlus.load_config("spec/fixtures/private_pub.yml", "production")
    PrivatePubPlus.config[:server].should eq("http://example.com/faye")
    PrivatePubPlus.config[:secret_token].should eq("PRODUCTION_SECRET_TOKEN")
    PrivatePubPlus.config[:signature_expiration].should eq(600)
  end

  it "raises an exception if an invalid environment is passed to load_config" do
    lambda {
      PrivatePubPlus.load_config("spec/fixtures/private_pub.yml", :test)
    }.should raise_error ArgumentError
  end

  it "includes channel, server, and custom time in subscription" do
    PrivatePubPlus.config[:server] = "server"
    subscription = PrivatePubPlus.subscription(:timestamp => 123, :channel => "hello")
    subscription[:timestamp].should eq(123)
    subscription[:channel].should eq("hello")
    subscription[:server].should eq("server")
  end

  it "does a sha1 digest of channel, timestamp, and secret token" do
    PrivatePubPlus.config[:secret_token] = "token"
    subscription = PrivatePubPlus.subscription(:timestamp => 123, :channel => "channel")
    subscription[:signature].should eq(Digest::SHA1.hexdigest("tokenchannel123"))
  end

  it "formats a message hash given a channel and a string for eval" do
    PrivatePubPlus.config[:secret_token] = "token"
    PrivatePubPlus.message("chan", "foo").should eq(
      :ext => {:private_pub_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :eval => "foo"
      }
    )
  end

  it "formats a message hash given a channel and a hash" do
    PrivatePubPlus.config[:secret_token] = "token"
    PrivatePubPlus.message("chan", :foo => "bar").should eq(
      :ext => {:private_pub_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :data => {:foo => "bar"}
      }
    )
  end

  it "publish message as json to server using Net::HTTP" do
    PrivatePubPlus.config[:server] = "http://localhost"
    message = 'foo'
    form = mock(:post).as_null_object
    http = mock(:http).as_null_object

    Net::HTTP::Post.should_receive(:new).with('/').and_return(form)
    form.should_receive(:set_form_data).with(message: 'foo'.to_json)

    Net::HTTP.should_receive(:new).with('localhost', 80).and_return(http)
    http.should_receive(:start).and_yield(http)
    http.should_receive(:request).with(form).and_return(:result)

    PrivatePubPlus.publish_message(message).should eq(:result)
  end

  it "it should use HTTPS if the server URL says so" do
    PrivatePubPlus.config[:server] = "https://localhost"
    http = mock(:http).as_null_object

    Net::HTTP.should_receive(:new).and_return(http)
    http.should_receive(:use_ssl=).with(true)

    PrivatePubPlus.publish_message('foo')
  end

  it "it should not use HTTPS if the server URL says not to" do
    PrivatePubPlus.config[:server] = "http://localhost"
    http = mock(:http).as_null_object

    Net::HTTP.should_receive(:new).and_return(http)
    http.should_receive(:use_ssl=).with(false)

    PrivatePubPlus.publish_message('foo')
  end

  it "raises an exception if no server is specified when calling publish_message" do
    lambda {
      PrivatePubPlus.publish_message("foo")
    }.should raise_error(PrivatePubPlus::Error)
  end

  it "publish_to passes message to publish_message call" do
    PrivatePubPlus.should_receive(:message).with("chan", "foo").and_return("message")
    PrivatePubPlus.should_receive(:publish_message).with("message").and_return(:result)
    PrivatePubPlus.publish_to("chan", "foo").should eq(:result)
  end

  it "has a Faye rack app instance" do
    PrivatePubPlus.faye_app.should be_kind_of(Faye::RackAdapter)
  end

  it "says signature has expired when time passed in is greater than expiration" do
    PrivatePubPlus.config[:signature_expiration] = 30*60
    time = PrivatePubPlus.subscription[:timestamp] - 31*60*1000
    PrivatePubPlus.signature_expired?(time).should be_true
  end

  it "says signature has not expired when time passed in is less than expiration" do
    PrivatePubPlus.config[:signature_expiration] = 30*60
    time = PrivatePubPlus.subscription[:timestamp] - 29*60*1000
    PrivatePubPlus.signature_expired?(time).should be_false
  end

  it "says signature has not expired when expiration is nil" do
    PrivatePubPlus.config[:signature_expiration] = nil
    PrivatePubPlus.signature_expired?(0).should be_false
  end
end
