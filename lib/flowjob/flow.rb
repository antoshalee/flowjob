require 'active_support/inflector'

module Flowjob
  class Flow
    class NoJobError < StandardError; end
    attr_reader :context

    def self.run(context, options = {})
      flow = new(context, options)
      yield(flow)
    end

    def method_missing(method, *args, &block)
      job_class = begin
        "#{@namespace}::#{method.to_s.camelize}".constantize
      rescue
        raise NoJobError, "Unregistered job '#{method}'"
      end
      job = job_class.new(@context)
      job.call(*args)
    end

    def initialize(context, options = {})
      @context = context
      @namespace = options[:namespace] || "Flowjob::Jobs"
    end
  end
end
