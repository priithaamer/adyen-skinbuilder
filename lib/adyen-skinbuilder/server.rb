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
          Adyen::Admin::Skin.new(:path => settings.skins_directory)
          File.dirname(settings.skins_directory)
        rescue ArgumentError
          settings.skins_directory
        end
      end

      def skin_path(*path)
        File.join(skins_directory, *path)
      end

      def skin_file(skin_code)
        skin_path(skin_code, "skin.html").tap do |file|
          if !File.exists?("#{file}.erb")
            file.replace File.join(settings.views, "skin.html")
          end
        end
      end

      def store(output)
        output.scan(/<!-- ### inc\/([a-z]+) -->(.+?)<!-- ### -->/m) do |name, content|
          file = skin_path @skin_code, "/inc/#{name}.txt"
          `mkdir -p #{File.dirname(file)}`
          File.open(file, "w") do |f|
            f.write content.strip
          end
        end
      end

      def adyen_login
        if settings.adyen_admin_cfg && !Adyen::Admin.authenticated?
          cfg = settings.adyen_admin_cfg
          Adyen::Admin.login(cfg[:accountname], cfg[:username], cfg[:password])
        end
      end

      helpers Helper::Render, Helper::Adyen

      get '/sf/:skin_code/*' do |skin_code, path|
        if (file = skin_path(skin_code, path)) && File.exists?(file)
          send_file file
        elsif (file = skin_path("base", path)) && File.exists?(file)
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

      # skin page
      get '/:skin_code' do |skin_code|
        @skin_code = skin_code

        erb(skin_file(@skin_code).to_sym, {
          :views => '/',
          :layout => File.join(settings.views, "layout.html").to_sym
        }).tap do |output|
          if @skin = Adyen::Admin::Skin.new(:path => skin_path(skin_code))
            if params[:compile]
              store(output)
              send_file(@skin.compile) && return
            elsif params[:upload]
              store(output)
              adyen_login
              @skin.upload
            end
          end
        end
      end

      # cache remote skins
      @@skin_cache = nil

      # index page
      get '/' do
        Adyen::Admin::Skin.default_path = skin_path
        if params[:sync]
          Adyen::Admin::Skin.purge_cache
          adyen_login
          @@skin_cache = Adyen::Admin::Skin.all
        end
        if params[:download] && (@skin = Adyen::Admin::Skin.find(params[:download]))
          @skin.download.tap do |zip_file|
            @skin.decompile(zip_file)
            `cp #{skin_file(@skin.code)}.erb #{@skin.path}`
            `rm -f #{zip_file}`
          end
        end
        @skins = @@skin_cache || Adyen::Admin::Skin.all_local
        @adyen_admin_cfg = settings.adyen_admin_cfg

        erb 'index.html'.to_sym, :layout => false
      end
    end
  end
end
