module Adyen
  module SkinBuilder
    module Helper
      module Render
        def store(output)
          output.scan(/<!-- ### inc\/([a-z]+) -->(.+?)<!-- ### -->/m) do |name, content|
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
      end
    end
  end
end
