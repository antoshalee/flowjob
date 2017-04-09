module Flowjob
  module Jobs
    class Base
      class << self
        attr_accessor :context_readers, :context_writers

        def inherited(base)
          base.context_readers = []
          base.context_writers = []
        end

        def context_reader(*accessors)
          @context_readers += accessors
        end

        def context_writer(*accessors)
          @context_writers += accessors
        end

        def desc(desc)
          @desc = desc
        end
      end

      def initialize(context)
        @context = context
      end

      def write_context(key, value)
        if self.class.context_writers.include?(key)
          @context[key] = value
        else
          raise Flowjob::Errors::ForbiddenContextAccess
        end
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
