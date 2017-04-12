require 'flowjob/version'
require 'flowjob/jobs'
require 'flowjob/flow'
require 'flowjob/context_wrapper'
require 'flowjob/errors'

module Flowjob
  class << self
    def explain(job)
      job_class = "Flowjob::Jobs::#{job.to_s.camelize}".constantize
      desc = job_class.instance_variable_get(:@desc)
      readers = job_class.context_readers.to_a
      desc << ". It reads #{[readers].join(', ')}" unless readers.empty?
      desc
    end
  end
end
