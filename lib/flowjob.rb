require 'flowjob/version'
require 'flowjob/jobs'
require 'flowjob/jobs/base'
require 'flowjob/flow'
require 'flowjob/errors'

module Flowjob
  class << self
    def explain(job)
      job_class = "Flowjob::Jobs::#{job.to_s.camelize}".constantize
      desc = job_class.instance_variable_get(:@desc)
      readers = job_class.context_readers
      desc << ". It reads #{[readers].join(', ')}" unless readers.empty?
      desc
    end
  end
end
