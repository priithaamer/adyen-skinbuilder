module Adyen
  module SkinBuilder
    module Helper
      module Adyen

        # start the adyen form, if no block padded payment fields are auto included
        def adyen_form_tag(&block)
          buffer << render_partial(:adyen_form, :views => settings.views, :block => block)
        end

        # render the payment fields
        def adyen_payment_fields(&block)
          if block_given?
            capture &block
          else
            render_partial :adyen_payment_fields, :views => settings.views
          end
        end

        # to be done
        # def adyen_custom_field_tag
        # end
        #
        # def adyen_custom_hidden_tag
        # end

        ## autofill cc
        ## autofill avs
      end
    end
  end
end
