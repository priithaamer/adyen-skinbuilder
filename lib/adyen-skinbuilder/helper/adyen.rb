module Adyen
  module SkinBuilder
    module Helper
      module Adyen

        def adyen_form_tag(&block)
          buffer << render_partial(:adyen_form, :views => settings.views, :block => block)
        end

        def adyen_payment_fields(&block)
          if block_given?
            capture &block
          else
            render_partial :adyen_payment_fields, :views => settings.views
          end
        end

        def adyen_custom_field_tag
        end

        def adyen_custom_hidden_tag
        end
      end
    end
  end
end
