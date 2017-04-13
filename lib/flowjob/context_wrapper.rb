module Flowjob
  class ContextWrapper
    extend Forwardable

    attr_reader :data

    def_delegators :@resolver, :allow_readers, :allow_writers

    def initialize(data)
      @data = data
      @resolver = MethodResolver.new(self)
    end

    def method_missing(method, *args)
      @resolver.resolve(method, args.first)
    end

    def respond_to_missing?(method, _include_private)
      @resolver.will_be_resolved?(method)
    end

    # Methods responsible for accessing are extracted to separate resolver
    # to be more safe with `method_missing`
    class MethodResolver
      attr_reader :data

      def initialize(context)
        @data = context.data
        @allowed_readers = []
        @allowed_writers = []
      end

      def allow_readers(*readers)
        @allowed_readers = readers
      end

      def allow_writers(*writers)
        @allowed_writers = writers
      end

      def resolve(method, value)
        if method_is_writer?(method)
          write(method, value)
        else
          read(method)
        end
      end

      def will_be_resolved?(method)
        allowed_writer?(method) || allowed_reader?(method)
      end

      private

      def write(method, value)
        raise_forbidden(method) unless allowed_writer?(method)

        @data[method[0..-2].to_sym] = value
      end

      def read(method)
        raise_forbidden(method) unless allowed_reader?(method)

        @data[method]
      end

      def method_is_writer?(method)
        method.to_s.end_with?('='.freeze)
      end

      def allowed_writer?(method)
        return false unless method_is_writer?(method)
        @allowed_writers.include?(method[0..-2].to_sym)
      end

      def allowed_reader?(method)
        @allowed_readers.include?(method)
      end

      def raise_forbidden(method)
        raise Flowjob::Errors::ForbiddenContextAccess,
              "Please define context accessor for `#{method}`"
      end
    end
  end
end
