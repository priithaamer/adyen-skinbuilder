require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'adyen-skinbuilder/helper/adyen'
require 'adyen-skinbuilder/helper/render'

require 'adyen-admin'

require 'i18n'

module Adyen
  module SkinBuilder
    class Server < Sinatra::Base
      dir = File.dirname(File.expand_path(__FILE__))

      set :views, "#{dir}/server/views"
      set :server, 'webrick'

      # method will be overwritten by _vegas_ if skin directory given
      def self.skins_directory
        File.expand_path(".")
      end

      def self.skins_directory=(dir)
        @@skins_directory = dir
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

      def render_skin(skin, locals = {})
        erb(skin_erb_file(skin).to_sym, {
          :views => '/',
          :layout => File.join(settings.views, "layout.html").to_sym,
          :locals => locals,
        })
      end

      helpers Helper::Render, Helper::Adyen

      before do
        if settings.respond_to?(:i18n_path) && settings.i18n_path
          @locale = params.fetch('locale', 'en')
          @locale_suffix = "_#{@locale}"

          I18n.load_path = Dir[File.join(settings.i18n_path, '*yml')]
          I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
          I18n.locale = @locale
        else
          @locale_suffix = ''
        end
      end

      get '/sf/:skin_code/*' do |skin_code, path|
        if skin = Adyen::Admin::Skin.find(skin_code)
          if (file = skin.get_file(path)) && File.exists?(file)
            send_file file
          elsif (file = File.join(skins_directory, skin.parent_skin, path)) && File.exists?(file)
            send_file file
          end
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
          @skin.compile(render_skin(@skin))
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
          @locale_suffix = ''
          @skin.compile(render_skin(@skin))

          I18n.available_locales.each do |locale|
            I18n.locale = locale
            @locale_suffix = "_#{locale}"
            @skin.compile(render_skin(@skin))
          end
          send_file(@skin.compress, :filename => "#{skin_code}.zip")
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
          render_skin @skin, { :default_data => @skin.default_data }
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
