module Flowjob
  module Actions
    class Base
      attr_reader :context

      class << self
        attr_accessor :context_readers

        def inherited(base)
          base.context_readers = []
        end

        def context_reader(*accessors)
          @context_readers += accessors
        end

        def desc(desc)
          @desc = desc
        end
      end

      def initialize(context)
        @context = context
      end

      def method_missing(method, *args, &block)
        if self.class.context_readers.include?(method)
          @context[method]
        else
          super
        end
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
