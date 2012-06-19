require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'adyen-skinbuilder/helper/adyen'
require 'adyen-skinbuilder/helper/render'

require 'adyen-admin'

module Adyen
  module SkinBuilder
    class Server < Sinatra::Base
      dir = File.dirname(File.expand_path(__FILE__))

      set :views, "#{dir}/server/views"

      # method will be overwritten by _vegas_ if skin directory given
      def self.skins_directory
        File.expand_path(".")
      end

      def self.adyen_admin_cfg
        nil
      end

      def skins_directory
        @@skins_directory ||= begin
          # check if it's a skin, if so use dirname
          Adyen::Admin::Skin.new(:path => settings.skins_directory)
          File.dirname(settings.skins_directory)
        rescue ArgumentError
          settings.skins_directory
        end
      end

      def skin_file(skin, filename)
        skin.get_file(filename).tap do |file|
          if !File.exists?(file)
            return File.join(settings.views, filename)
          end
        end
      end

      def skin_erb_file(skin, filename = "skin.html")
        if file = skin_file(skin, "#{filename}.erb")
          return file.gsub(".erb", "")
        end
      end

      def adyen_login
        if (cfg = settings.adyen_admin_cfg) && !Adyen::Admin.authenticated?
          Adyen::Admin.login(cfg[:accountname], cfg[:username], cfg[:password])
        end
      end

      def render_skin(skin)
        erb(skin_erb_file(skin).to_sym, {
          :views => '/',
          :layout => File.join(settings.views, "layout.html").to_sym
        })
      end

      helpers Helper::Render, Helper::Adyen

      get '/sf/:skin_code/*' do |skin_code, path|
        if (skin = Adyen::Admin::Skin.find(skin_code)) && (file = skin.get_file(path)) && File.exists?(file)
          send_file file
        elsif (file = File.join(skins_directory, "base", path)) && File.exists?(file)
          send_file file
        end
      end

      get '/hpp/*' do |path|
        send_file File.join(settings.views, path).tap { |file|
          if !File.exists?(file)
            `mkdir -p #{File.dirname(file)}`
            `wget https://test.adyen.com/hpp/#{path} -O #{file}`
          end
        }
      end

      get '/favicon.ico' do
      end

      get '/:skin_code/upload' do |skin_code|
        if @skin = Adyen::Admin::Skin.find(skin_code)
          output = render_skin @skin
          @skin.compile(output)
          @skin.upload
        end
        redirect '/sync'
      end

      get '/:skin_code/download' do |skin_code|
        if @skin = Adyen::Admin::Skin.find(skin_code)
          @skin.download.tap do |zip_file|
            @skin.decompile(zip_file)
            `cp #{skin_erb_file(@skin)}.erb #{@skin.path}`
            `rm -f #{zip_file}`
          end
        end
        redirect '/'
      end

      get '/:skin_code/update' do |skin_code|
        if @skin = Adyen::Admin::Skin.find(skin_code)
          @skin.update
        end
        redirect '/sync'
      end

      get '/:skin_code/compile' do |skin_code|
        if @skin = Adyen::Admin::Skin.find(skin_code)
          output = render_skin @skin
          @skin.compile(output)
          send_file(@skin.compress)
        else
          redirect '/'
        end
      end

      get '/sync' do
        Adyen::Admin::Skin.default_path = skins_directory
        Adyen::Admin::Skin.purge_cache
        adyen_login
        redirect '/'
      end

      # skin page
      get '/:skin_code' do |skin_code|
        if @skin = Adyen::Admin::Skin.find(skin_code)
          render_skin @skin
        else
          redirect '/'
        end
      end

      # index page
      get '/' do
        Adyen::Admin::Skin.default_path = skins_directory
        @skins = Adyen::Admin::Skin.all
        @adyen_admin_cfg = settings.adyen_admin_cfg

        erb 'index.html'.to_sym, :layout => false
      end
    end
  end
end
