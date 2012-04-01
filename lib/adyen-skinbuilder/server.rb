require 'sinatra/base'

module Adyen
  module SkinBuilder
    def is_skin?(path)
      File.exists?("#{path}/skin.html.erb") || File.exists?("#{path}/inc") || File.exists?("#{path}/css")  || File.exists?("#{path}/js")
    end
    module_function :is_skin?

    class Server < Sinatra::Base
      dir = File.dirname(File.expand_path(__FILE__))

      set :views, "#{dir}/server/views"

      # method will be overwritten by _vegas_ if skin directory given
      def self.skins_directory
        File.expand_path(".")
      end

      def skins_directory
        @@skins_directory ||= if Adyen::SkinBuilder.is_skin?(settings.skins_directory)
          File.dirname(settings.skins_directory)
        else
          settings.skins_directory
        end
      end

      def skin_path(*path)
        File.join(skins_directory, *path)
      end

      helpers do
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
          erb "_#{file}.html".to_sym, :layout => false, :locals => locals
        end

        def adyen_form_tag(&block)
          buffer << render_partial(:adyen_form, :block => block)
        end

        def adyen_payment_fields(&block)
          if block_given?
            capture &block
          else
            render_partial :adyen_payment_fields
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
        send_file File.join(settings.views, path).tap do |file|
          if !File.exists?(file)
            `mkdir -p #{File.dirname(file)}`
            `wget https://test.adyen.com/hpp/#{path} -O #{file}`
          end
        end
      end

      get '/favicon.ico' do
      end

      get '/:skin_code' do |skin_code|
        @skin_code = skin_code

        file = skin_path skin_code, "skin.html"
        if !File.exists?("#{file}.erb")
          file = File.join(settings.views, "skin.html")
        end
        erb file.to_sym, :views => '/', :layout => File.join(settings.views, "layout.html").to_sym
      end

      get '/' do
        skins = Dir[skin_path("/*")].map do |path|
          File.basename(path) if Adyen::SkinBuilder.is_skin?(path)
        end.compact

        erb :'index.html', :layout => false, :locals => { :skins => skins }
      end
    end
  end
end
