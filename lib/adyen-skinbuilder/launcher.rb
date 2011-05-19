require 'slop'

module Adyen
  module SkinBuilder
    class Launcher
      
      def self.ignition(*argv)
        opts = Slop.parse do
          banner "\nUsage: adyen-skinbuilder [options] path\n"
        
          on :P, :port, 'Port, defaults to 8888', true, :default => 8888
          on :l, :log, 'Show server log'
          on :V, :version, 'Print the version' do
            puts "Adyen Skinbuilder version #{Adyen::Skinbuilder::VERSION}"
            exit
          end
          on :h, :help, 'Print this help message' do
            puts help
            exit
          end
        end
        
        # If skins directory is not provided or does not exist
        if opts.parse.empty? or not File.exists?(File.expand_path(opts.parse.last))
          puts opts.help
          exit
        end
        
        puts "Using skin directory #{File.expand_path(opts.parse.last)}"
        puts "Running server at http://localhost:#{opts[:port]}/"
        
        Adyen::SkinBuilder::Server.run({
          :port => opts[:port],
          :log => opts[:log],
          :skins_directory => File.expand_path(opts.parse.last)
        })
      end
    end
  end
end
