require "flowjob/version"
require "flowjob/actions"
require "flowjob/actions/base"
require "flowjob/flow"

module Flowjob
  class << self
    def explain(action)
      action_class = "Flowjob::Actions::#{action.to_s.camelize}".constantize
      desc = action_class.instance_variable_get(:@desc)
      readers = action_class.context_readers
      unless readers.empty?
        desc << ". It reads #{[readers].join(', ')}"
      end
      desc
    end
  end
end
