require 'active_support/inflector'

module Flowjob
  class Flow
    attr_reader :context

    def self.run(context, options = {})
      flow = new(context, options)
      yield(flow)
    end

    def method_missing(method, *args)
      job_class = begin
        "#{@namespace}::#{method.to_s.camelize}".constantize
      rescue
        raise Flowjob::Errors::NoJobError, "Unregistered job '#{method}'"
      end
      job = job_class.new(@context)
      job.call(*args)
    end

    DEFAULT_NAMESPACE = 'Flowjob::Jobs'.freeze

    def initialize(context, options = {})
      @context = context
      @namespace = options[:namespace] || DEFAULT_NAMESPACE
    end
  end
end
