require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'rack/test'

describe 'SkinBuilder server' do

  include Rack::Test::Methods

  def app
    Adyen::SkinBuilder::Server.app(
      :skins_directory => File.expand_path(File.join(File.dirname(__FILE__), '../../fixtures/skins/DV3tf95f'))
    )
  end
  
  describe 'get asset from skin directory' do
    before(:each) do
      get '/sf/DV3tf95f/css/screen.css'
    end
    
    it 'responds with 200 status' do
      last_response.status.should == 200
    end
    
    it 'responds with "text/css" content type header for CSS file' do
      last_response.headers.fetch('Content-Type').should == 'text/css'
    end
  end
  
  describe 'get asset from skins base directory' do
    before(:each) do
      get '/sf/DV3tf95f/css/print.css'
    end
    
    it 'responds with 200 status' do
      last_response.status.should == 200
    end
    
    it 'responds with "text/css" content type header for CSS file' do
      last_response.headers.fetch('Content-Type').should == 'text/css'
    end
  end
  
  describe 'GET /' do
    before(:each) do
      get '/'
    end
    
    it 'responds with 200 status' do
      last_response.status.should == 200
    end
    
    it 'returns adyen skeleton in HTML format' do
      last_response.headers.fetch('Content-Type').should == 'text/html'
    end
  end
  
  describe 'HEAD /' do
    before(:each) do
      head '/'
    end
    
    it 'responds withr 200 status' do
      last_response.status.should == 200
    end
    
    it 'returns content type header' do
      last_response.headers.should == { 'Content-Type' => 'text/html' }
    end
    
    it 'returns empty body' do
      last_response.body.should == ''
    end
  end
end
