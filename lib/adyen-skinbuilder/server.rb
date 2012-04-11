require 'rubygems'
require "bundler/setup"

require 'sinatra/base'
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

      helpers do
        def store
          buffer.scan(/<!-- ### inc\/([a-z]+) -->(.+?)<!-- ### -->/m) do |name, content|
            file = skin_path @skin_code, "/inc/#{name}.txt"
            `mkdir -p #{File.dirname(file)}`
            File.open(file, "w") do |f|
              f.write content.strip
            end
          end
        end

        def buffer
          @_out_buf || @_buf
        end

        def capture
          pos = buffer.size
          yield
          buffer.slice!(pos..buffer.size)
        end

        def load(file)
          file = skin_path @skin_code, "/inc/#{file}.txt"
          File.read(file) if File.exists?(file)
        end

        def render_partial(file, locals = {})
          views = locals.delete(:views) || skin_path(@skin_code)
          erb "_#{file}.html".to_sym, :layout => false, :views => views, :locals => locals
        end

        def adyen_form_tag(&block)
          buffer << render_partial(:adyen_form, :views => settings.views, :block => block)
        end

        def adyen_payment_fields(&block)
          if block_given?
            capture &block
          else
            render_partial :adyen_payment_fields, :views => settings.views
          end
        end
      end

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

      get '/:skin_code' do |skin_code|
        @skin_code = skin_code

        if params[:upload]
          @skin = Adyen::Admin::Skin.new(:path => skin_path(skin_code))
          @skin.upload
        end

        erb skin_file(@skin_code).to_sym, :views => '/', :layout => File.join(settings.views, "layout.html").to_sym
      end

      get '/' do
        @skins = Adyen::Admin::Skin.all_remote | Adyen::Admin::Skin.all_local(skin_path)

        erb 'index.html'.to_sym, :layout => false
      end
    end
  end
end
