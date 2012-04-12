
require 'spec_helper'
require 'rack/test'

describe 'SkinBuilder server' do
  include Rack::Test::Methods

  let(:skins_directory) { File.expand_path(File.join(File.dirname(__FILE__), '../../fixtures/skins')) }
  let(:skin_code) { "/DV3tf95f" }

  def app
    Adyen::SkinBuilder::Server.tap do |app|
      app.set :skins_directory, skins_directory
    end.new
  end

  describe 'get asset from skin directory' do
    let(:file) { '/css/screen.css' }

    before(:each) do
      get "/sf" + skin_code + file
    end

    it 'responds with 200 status' do
      last_response.status.should == 200
    end

    it 'responds with "text/css" content type header for CSS file' do
      last_response.headers.fetch('Content-Type').should == 'text/css;charset=utf-8'
    end

    it 'returns file content' do
      last_response.body.should == File.read(skins_directory + skin_code + file)
    end
  end

  describe 'get asset from skins base directory' do
    let(:file) { '/css/print.css' }

    before(:each) do
      get '/sf' + skin_code + file
    end

    it 'responds with 200 status' do
      last_response.status.should == 200
    end

    it 'responds with "text/css" content type header for CSS file' do
      last_response.headers.fetch('Content-Type').should == 'text/css;charset=utf-8'
    end

    it 'returns file content' do
      last_response.body.should == File.read(skins_directory + "/base" + file)
    end
  end

  describe 'GET /' do
    before(:each) do
      get path
    end

    context "index" do
      let(:path) { '/' }

      it 'responds with 200 status' do
        last_response.status.should == 200
      end

      it 'returns adyen skeleton in HTML format' do
        last_response.headers.fetch('Content-Type').should == 'text/html;charset=utf-8'
      end

      it 'returns skins_directory' do
        last_response.body.should include(skins_directory)
      end

      it 'returns avilable skins' do
        last_response.body.should include(skin_code)
      end
    end

    context "skin" do
      let(:path) { skin_code }

      it 'responds with 200 status' do
        last_response.status.should == 200
      end

      it 'returns adyen skeleton in HTML format' do
        last_response.headers.fetch('Content-Type').should == 'text/html;charset=utf-8'
      end

      it 'returns adyen form' do
        last_response.body.should include('<form id="pageform" action="" method="post" onsubmit="return formValidate(this);">')
      end

      it 'returns order data' do
        last_response.body.should include(File.read(skins_directory + skin_code + '/inc/order_data.txt'))
      end
    end

    context "one file skin" do
      let(:skin_code) { "/JH0815" }
      let(:path) { skin_code + '?upload=true'}

      after do
        FileUtils.rm_rf(skins_directory + skin_code + '/inc')
      end

      it 'writes cheader' do
        File.read(skins_directory + skin_code + '/inc/cheader.txt').should == "<!-- ### inc/cheader_[locale].txt or inc/cheader.txt (fallback) ### -->"
      end

      it 'writes pmheader' do
        File.read(skins_directory + skin_code + '/inc/pmheader.txt').should == "<!-- ### inc/pmheader_[locale].txt or inc/pmheader.txt (fallback) ### -->"
      end

      it 'writes pmfooter' do
        File.read(skins_directory + skin_code + '/inc/pmfooter.txt').should == "<!-- ### inc/pmfooter_[locale].txt or inc/pmfooter.txt (fallback) ### -->\n\n  <!-- ### inc/customfields_[locale].txt or inc/customfields.txt (fallback) ### -->"
      end

      it 'writes cfooter' do
        File.read(skins_directory + skin_code + '/inc/cfooter.txt').should == "<!-- ### inc/cfooter_[locale].txt or inc/cfooter.txt (fallback) ### -->"
      end
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
      last_response.headers.fetch('Content-Type').should == 'text/html;charset=utf-8'
    end

    it 'returns empty body' do
      last_response.body.should == ''
    end
  end
end
