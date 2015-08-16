module Flowing
  module Actions
    class Base
      attr_reader :context

      class << self
        def context_reader(*accessors)
          accessors.each do |accessor|
            define_method accessor do
              return context[accessor]
            end
          end
        end

        def desc(desc)
          @desc = desc
        end
      end

      def initialize(context)
        @context = context
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
