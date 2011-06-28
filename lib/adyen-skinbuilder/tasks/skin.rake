require 'adyen-skinbuilder'
require 'zip/zip'

namespace :adyen do
  namespace :skin do
    
    desc 'Run server to test Adyen skins. Run as rake adyen:skin:server[/path/to/skin/directory]'
    task :server, :skin_directory do |t, args|
      port, skin_directory = 8888, File.expand_path(args[:skin_directory])
      
      puts "Using skin directory #{skin_directory}"
      puts "Running server at http://localhost:#{port}/"
      
      Adyen::SkinBuilder::Server.run({:port => port, :log => false, :skin_directory => skin_directory})
    end
    
    desc 'Build adyen skin zip file for upload. Provide SKIN and TARGET environment variables along the way.'
    task :build, :skin_directory, :target_directory do |t, args|
      skin_directory = File.expand_path(args[:skin_directory] || ENV['SKIN'])
      base_directory = File.expand_path(File.join(skin_directory, '..', 'base'))
      # Allow the folder of a skin to have a meaningful name in this format:
      # some-nice-name-SKINCODE (use a dash as last charachter before SKINCODE)
      # Give the zip the full name, but give the top level directory in the zip
      # archive only the SKINCODE, otherwise adyen will not accept it
      skin_name = File.basename(skin_directory)
      skin_code = skin_name[/(?<=\-)[a-zA-Z0-9]+$/] || skin_name
      target_directory = File.expand_path((args[:target_directory] || ENV['TARGET']))

      # Wether we do or do not have/use a base directory
      use_base = File.directory?(base_directory)
      puts use_base ? "Using base directory" : "Not using a base directory"

      if File.directory?(skin_directory) and File.directory?(target_directory)
        Zip::ZipOutputStream::open(File.join(target_directory, "#{skin_name}.zip")) do |io|
          %w(css img inc js res).each do |d|
            # First see what files the skin itself provides: 
            if File.directory?(File.join(skin_directory, d))
              Dir.new(File.join(skin_directory, d)).each do |file|
                if File.file?(File.join(skin_directory, d, file))
                  io.put_next_entry("#{skin_code}/#{d}/#{file}")
                  io.write File.read(File.join(skin_directory, d, file))
                end
              end
            end
            # Then, let's see whether the base directory has more than what we got already:
            if use_base && File.directory?(File.join(base_directory, d))
              Dir.new(File.join(base_directory, d)).each do |file|
                # Only use base file if skin does not provide it itself:
                if !File.file?(File.join(skin_directory, d, file)) && File.file?(File.join(base_directory, d, file))
                  io.put_next_entry("#{skin_code}/#{d}/#{file}")
                  if File.file?(File.join(base_directory, d, file))
                    io.write File.read(File.join(base_directory, d, file))
                  end
                end
              end
            end
          end
        end
        puts "Skin zip package was created to #{File.join(target_directory, "#{skin_name}.zip")}"
      else
        puts "Usage: rake adyen:buildskin[<skin_directory>,<target_directory>] or rake:adyen:buildskin SKIN=/from/dir TARGET=/to/dir"
      end
    end
  end
end
