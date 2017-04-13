module Flowjob
  module Jobs
    class Base
      class << self
        attr_accessor :context_readers, :context_writers

        def inherited(job_class)
          %i(readers writers).each do |type|
            job_class.build_accessors(type)
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

        protected

        def build_accessors(type)
          superclass_accessors = superclass_accessors(type)

          send(
            "context_#{type}=",
            superclass_accessors && superclass_accessors.dup || Set.new
          )
        end

        def superclass_accessors(type)
          return nil unless superclass
          superclass.send("context_#{type}")
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
