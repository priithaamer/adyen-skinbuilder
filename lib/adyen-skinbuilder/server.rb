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

        erb 'index.html'.to_sym, :layout => false, :locals => { :skins => skins }
      end
    end
  end
end
