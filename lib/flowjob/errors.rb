module Flowjob
  module Errors
    class NoJobError < StandardError; end
    class ForbiddenContextAccess < StandardError; end
  end
end
