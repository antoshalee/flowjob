require "flowing/version"
require "flowing/actions"
require "flowing/actions/base"
require "flowing/flow"

module Flowing
  class << self
    def explain(action)
      "Flowing::Actions::#{action.to_s.camelize}".
        constantize.instance_variable_get(:@desc)
    end
  end
end
