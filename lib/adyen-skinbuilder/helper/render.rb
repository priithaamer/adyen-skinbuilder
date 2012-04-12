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
          file = skin_path @skin_code, "/inc/#{file}.txt"
          File.read(file) if File.exists?(file)
        end

         # render an erb partial inline
        def render_partial(file, locals = {})
          views = locals.delete(:views) || skin_path(@skin_code)
          erb "_#{file}.html".to_sym, :layout => false, :views => views, :locals => locals
        end
      end
    end
  end
end
