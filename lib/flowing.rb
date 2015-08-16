require "flowing/version"
require "flowing/actions"
require "flowing/actions/base"
require "flowing/flow"

module Flowing
  class << self
    def explain(action)
      action_class = "Flowing::Actions::#{action.to_s.camelize}".constantize
      desc = action_class.instance_variable_get(:@desc)
      readers = action_class.context_readers
      unless readers.empty?
        desc << ". It reads #{[readers].join(', ')}"
      end
      desc
    end
  end
end
