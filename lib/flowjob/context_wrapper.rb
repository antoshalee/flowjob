module Flowjob
  class ContextWrapper
    attr_reader :data

    def initialize(data)
      @data = data
      @allowed_readers = []
      @allowed_writers = []
    end

    def allow_readers(*readers)
      @allowed_readers = readers
    end

    def allow_writers(*writers)
      @allowed_writers = writers
    end

    def method_missing(method, *args)
      if method_is_writer?(method)
        try_to_write(method, args.first)
      else
        try_to_read(method)
      end
    end

    private

    def try_to_write(method, value)
      data_key = method[0..-2].to_sym
      raise_forbidden(data_key) unless @allowed_writers.include?(data_key)

      @data[data_key] = value
    end

    def try_to_read(method)
      raise_forbidden(method) unless @allowed_readers.include?(method)

      @data[method]
    end

    def raise_forbidden(method)
      raise Flowjob::Errors::ForbiddenContextAccess,
            "Please define `context_reader :#{method}`"
    end

    def method_is_writer?(method)
      method.to_s.end_with?('=')
    end
  end
end
