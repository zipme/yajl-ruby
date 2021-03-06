require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')
begin
  require 'yajl/bzip2'
rescue
  warn "Couldn't load yajl/bzip2, maybe you don't have bzip2-ruby installed? Continuing without running bzip2 specs."
end
require 'yajl/gzip'
require 'yajl/deflate'
require 'yajl/http_stream'

describe "Yajl HTTP error" do
  before(:all) do
    @request = File.new(File.expand_path(File.dirname(__FILE__) + "/fixtures/http.error.dump"), 'r')
    @uri = 'file://'+File.expand_path(File.dirname(__FILE__) + "/fixtures/http/http.error.dump")
    TCPSocket.should_receive(:new).and_return(@request)
    @request.should_receive(:write)
  end

  context "(without skip_http_error option)" do
    before(:all) do
      begin
        Yajl::HttpStream.get(@uri)
      rescue Yajl::HttpStream::HttpError => e
        @error = e
      end
    end
    it "should contain the error code in the message" do
      @error.message.should match(/404/)
    end

    it "should provide the HTTP response headers" do
      @error.headers.keys.should include('ETag', 'Content-Length', 'Server')
    end
  end

  context "(with skip_http_error option)" do
    it "should not raise error if opts['skip_http_error'] == true" do
      lambda { Yajl::HttpStream.get(@uri, :skip_http_error => true) }.should_not raise_error(Yajl::HttpStream::HttpError)
    end
  end

end