require 'spec_helper'

describe Flowjob::Flow do
  describe ".context_writer" do

    context "job with context" do
      class JobWitContextWriter < Flowjob::Jobs::Base
        context_writer :status

        def call
          write_context(:status, :ok)
        end
      end

      it "simply works" do
        context = {}
        job = JobWitContextWriter.new(context)
        job.call()
        expect(context[:status]).to eq(:ok)
      end
    end

    context "job without context_writer" do
      class JobWithoutContextWriter < Flowjob::Jobs::Base
        def call
          write_context(:status, :ok)
        end
      end

      it "raises exception" do
        job = JobWithoutContextWriter.new({})
        expect { job.call() }.to raise_error(Flowjob::Errors::ForbiddenContextAccess)
      end
    end
  end
end
