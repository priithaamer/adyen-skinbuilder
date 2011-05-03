require 'rack'

module Adyen
  module SkinBuilder
    class SkeletonAdapter
      
      def initialize(skin)
        @skin = skin
      end
      
      def call(env)
        body = File.read(File.join(File.dirname(__FILE__), '../../adyen/skeleton.html'))
        body = body.gsub(/\$skinCode/, 'lE00qtob')
        body = body.gsub(%r{\<!-- ### inc\/cheader_\[locale\].txt or inc\/cheader.txt \(fallback\) ### --\>}, '== C HEADER ==')
        body = body.gsub(%r{\<!-- ### inc\/pmheader_\[locale\].txt or inc\/pmheader.txt \(fallback\) ### --\>}, '== PM HEADER ==')
        body = body.gsub(%r{\<!-- ### inc\/pmfooter_\[locale\].txt or inc\/pmfooter.txt \(fallback\) ### --\>}, '== PM FOOTER ==')
        body = body.gsub(%r{\<!-- ### inc\/customfields_\[locale\].txt or inc\/customfields.txt \(fallback\) ### --\>}, '== CUSTOMFIELDS ==')
        body = body.gsub(%r{\<!-- ### inc\/cfooter_\[locale\].txt or inc\/cfooter.txt \(fallback\) ### --\>}, '== C FOOTER ==')
        body = body.gsub(%r{\<!-- Adyen Main Content --\>}, '== adyen main content ==')
        
        [200, {'Content-Type' => 'text/html'}, [body]]
      end
    end
    
    class Server
      
      class << self

        def run(config)
          handler = Rack::Handler.default
          handler.run(self.app(config), :Port => 8888, :AccessLog => [])
        end
      
        def app(config)
          Rack::Builder.app do
            use Rack::Head
            
            map("/sf/#{config[:skin]}") do
              run Rack::Cascade.new([
                Rack::File.new(File.join(config[:skins_directory], config[:skin])),
                Rack::File.new(File.join(config[:skins_directory], 'base'))
              ])
            end
        
            map('/') { run Adyen::SkinBuilder::SkeletonAdapter.new(config[:skin]) }
          end
        end
      end
    end
  end
end
