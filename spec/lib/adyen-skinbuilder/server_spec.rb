
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

  before do
    Adyen::Admin.stub(:login)
  end

  describe 'assets' do
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

    context 'file not available, falls back to base' do
      let(:file) { '/css/print.css' }

      it 'responds with 200 status' do
        last_response.status.should == 200
      end

      it 'responds with "text/css" content type header for CSS file' do
        last_response.headers.fetch('Content-Type').should == 'text/css;charset=utf-8'
      end

      it 'returns file content from base' do
        last_response.body.should == File.read(skins_directory + "/base" + file)
      end
    end
  end

  describe 'GET /' do
    context "split files skin" do
      before(:each) do
        get path
      end

      describe "index" do
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

      describe "skin" do
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
    end

    context "one file skin" do
      describe "compile" do
        let(:skin_code) { "/JH0815" }
        let(:path) { skin_code + "?compile=true" }

        before(:each) do
          get path
        end

        after do
          FileUtils.rm_rf(skins_directory + skin_code + '/inc')
          `rm JH0815.zip`
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

        it "returns zip file" do
          last_response.headers["Content-Type"].should == "application/zip"
        end
      end

      describe "upload" do
        let(:path) { skin_code + "?upload=true" }
        let!(:skin) { Adyen::Admin::Skin.new(:path => skins_directory + skin_code) }

        after do
          `rm -rf #{skins_directory + skin_code}/inc/*er.txt`
        end

        it "calls upload on skin" do
          Adyen::Admin::Skin.should_receive(:new).and_return(skin)
          skin.should_receive(:upload)
          get path
        end
      end

      describe "download" do
        let(:skin_code) { "vQW0fEo8" }
        let(:path) { "/?download=vQW0fEo8" }
        let(:skin) { Adyen::Admin::Skin.new(:code => skin_code) }

        before do
          `cp spec/fixtures/example.zip spec/fixtures/#{skin_code}.zip`
        end

        after do
          `rm -rf #{skin.path}`
        end

        it "call download on skin" do
          Adyen::Admin::Skin.should_receive(:find).and_return(skin)
          skin.should_receive(:download).and_return("spec/fixtures/#{skin_code}.zip")
          get path
          File.should be_exists("spec/fixtures/skins/#{skin_code}/skin.html.erb")
        end

        # it "copies skin template" do
        #   Adyen::Admin::Skin.should_receive(:find).and_return(skin)
        #   skin.should_receive(:download).and_return("spec/fixtures/#{skin_code}.zip")
        #   get path

        # end
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
