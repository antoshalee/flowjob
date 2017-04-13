module Flowjob
  module Jobs
    class Base
      class << self
        attr_accessor :context_readers, :context_writers

        def inherited(job_class)
          %i(readers writers).each do |type|
            build_accessors(job_class, type)
          end
        end

        def context_reader(*accessors)
          @context_readers += accessors
        end

        def context_writer(*accessors)
          @context_writers += accessors
        end

        def context_accessor(*accessors)
          @context_readers += accessors
          @context_writers += accessors
        end

        def desc(desc)
          @desc = desc
        end

        private

        def build_accessors(job_class, type)
          job_class.send(
            "context_#{type}=",
            parent_accessors(job_class, type) || Set.new
          )
        end

        def parent_accessors(job_class, type)
          return nil unless job_class.superclass
          accessors = job_class.superclass.send("context_#{type}")
          accessors && accessors.dup
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
