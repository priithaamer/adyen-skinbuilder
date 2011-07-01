require 'rack'

module Adyen
  module SkinBuilder
    class SkeletonAdapter
      
      def initialize(skins_directory)
        @skins_directory = File.dirname(skins_directory)
        @order_data_file = 
        @skin = File.basename(skins_directory)
      end
      
      def call(env)
        body = File.read(File.join(File.dirname(__FILE__), '../../adyen/skeleton.html'))
        body = body.gsub(/\$skinCode/, @skin)
        %w(cheader pmheader pmfooter customfields cfooter).each do |inc|
          body = body.gsub(%r{\<!-- ### inc\/#{inc}_\[locale\].txt or inc\/#{inc}.txt \(fallback\) ### --\>}, get_inc(inc))
        end
        body = body.gsub(%r{\<!-- Adyen Main Content --\>}, main_content)
        
        [200, {'Content-Type' => 'text/html'}, [body]]
      end
      
      private
      
      def main_content
        File.read(File.join(File.dirname(__FILE__), '../../adyen/main_content.html')).gsub(%r{\<!-- Adyen Order Data --\>}, get_inc('order_data'))
      end
      
      # TODO: add locale support so files like inc/cheader_[locale].txt will be included correctly
      def get_inc(filename)
        if File.exists?(File.join(@skins_directory, @skin, 'inc', "#{filename}.txt"))
          File.read(File.join(@skins_directory, @skin, 'inc', "#{filename}.txt"))
        elsif File.exists?(File.join(@skins_directory, 'base', 'inc', "#{filename}.txt"))
          File.read(File.join(@skins_directory, 'base', 'inc', "#{filename}.txt"))
        else
          "<!-- == #{filename}.txt IS MISSING == -->"
        end
      end
    end
   
    class Redirector 
      def call(env)    
        [302, {"Location" => "https://test.adyen.com#{env["REQUEST_PATH"]}"}, self]
      end
      def each(&block); end
    end
 
    class Server
      
      class << self

        def run(config)
          handler = Rack::Handler.default
          handler.run(self.app(config), :Port => config[:port], :AccessLog => [])
        end
      
        def app(config = {})
          Rack::Builder.app do
            use Rack::CommonLogger if config[:log]
            use Rack::Head
            
            map("/sf/#{File.basename(config[:skins_directory])}") do
              run Rack::Cascade.new([
                Rack::File.new(config[:skins_directory]),
                Rack::File.new(File.join(File.dirname(config[:skins_directory]), 'base'))
              ])
            end

            # Redirect requests for default assets to Adyen: 
            map("/hpp") { run Adyen::SkinBuilder::Redirector.new }
        
            map('/') { run Adyen::SkinBuilder::SkeletonAdapter.new(config[:skins_directory]) }
          end
        end
      end
    end
  end
end
