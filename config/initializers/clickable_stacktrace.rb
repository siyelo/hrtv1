#
# TO LOAD FUNCTIONALITY IN AN INITIALIZER
#

module ActionController
  module Rescue
    class << RESCUES_TEMPLATE_PATH
      def [](path)
        if Rails.root.join("app/views", path).exist?
          ActionView::Template::EagerPath.new_and_loaded(Rails.root.join("app/views").to_s)[path]
        else
          super
        end
      end
    end
  end
end
