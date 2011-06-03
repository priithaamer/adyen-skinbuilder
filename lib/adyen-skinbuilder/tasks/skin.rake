require 'adyen-skinbuilder'

namespace :adyen do
  namespace :skin do
    
    desc 'Run server to test Adyen skins. Run as rake adyen:skin:server[/path/to/skin/directory]'
    task :server, :skin_directory do |t, args|
      port = 8888
      
      puts "Using skin directory #{File.expand_path(args[:skin_directory])}"
      puts "Running server at http://localhost:#{port}/"
      
      Adyen::SkinBuilder::Server.run({:port => port, :log => false, :skin_directory => File.expand_path(args[:skin_directory])})
    end
  end
end
