require 'active_support/inflector'

module Flowjob
  class Flow
    class << self
      def run(context_data, options = {})
        context = Context.new(context_data.dup)

        yield new(context, options)

        context
      end
    end

    attr_reader :context

    DEFAULT_NAMESPACE = 'Flowjob::Jobs'.freeze

    def initialize(context, options = {})
      @context = context
      @namespace = options.fetch(:namespace, DEFAULT_NAMESPACE)
    end

    def method_missing(method, *args)
      job_class(method)
        .new(context)
        .call(*args)
    end

    private

    attr_reader :namespace

    def job_class(method)
      "#{namespace}::#{method.to_s.camelize}".constantize
    rescue NameError
      raise Flowjob::Errors::NoJobError, "Unregistered job '#{method}'"
    end
  end
end
