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
        @context.allow_readers(*self.class.context_readers)
        @context.allow_writers(*self.class.context_writers)
      end

      attr_reader :context

      def call
        raise NotImplementedError
      end
    end
  end
end
