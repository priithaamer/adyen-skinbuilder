module Adyen
  module SkinBuilder
    module Helper
      module Render

        # the output buffer
        def buffer
          @_out_buf || @_buf
        end

        # capture rednered output to a string
        def capture
          pos = buffer.size
          yield
          buffer.slice!(pos..buffer.size)
        end

        # renders a file from the inc folder of the skin
        def render_file(file)
          file = File.join(@skin.path, "inc/#{file}.txt")
          File.read(file) if File.exists?(file)
        end

         # render an erb partial inline
        def render_partial(file, locals = {})
          views = locals.delete(:views) || @skin.path
          erb inject_underscore(file).to_sym, :layout => false, :views => views, :locals => locals
        end

        private
        def inject_underscore(path)
          path.to_s.split('/').tap do |path|
            path[-1] = "_#{path.last}.html"
          end.join("/")
        end
      end
    end
  end
end
