module Adyen
  module SkinBuilder
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'adyen-skinbuilder/tasks/skin.rake'
      end
    end
  end
end
