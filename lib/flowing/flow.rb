require 'active_support/inflector'

module Flowing
  class Flow
    class NoActionError < StandardError; end
    attr_reader :context

    def self.run(context, options = {})
      flow = new(context, options)
      yield(flow)
    end

    def method_missing(method, *args, &block)

      action_class = begin
        "#{@namespace}::#{method.to_s.camelize}".constantize
      rescue
        raise NoActionError, "Unregistered action '#{method}'"
      end
      action = action_class.new(@context)
      action.call(*args)
    end

    def initialize(context, options = {})
      @context = context
      @namespace = options[:namespace] || "Flowing::Actions"
    end
  end
end
