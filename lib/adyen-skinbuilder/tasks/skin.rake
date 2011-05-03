require 'adyen-skinbuilder'

namespace :adyen do
  namespace :skin do
    
    desc 'Run server to test Adyen skins'
    task :server do
      puts "Starting server at http://localhost:8888/"
      
      Adyen::SkinBuilder::Server.run(:skin => 'lE00qtob')
    end
  end
end
