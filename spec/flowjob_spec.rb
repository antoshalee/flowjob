require 'spec_helper'

describe Flowjob do
  it 'has a version number' do
    expect(Flowjob::VERSION).not_to be nil
  end

  describe ".explain" do
    class Flowjob::Actions::Populate < Flowjob::Actions::Base
      desc "Populates context with needed data"

      context_reader :config
      context_reader :time_range, :status

      def call
        "I am populating"
      end
    end

    class Flowjob::Actions::NoReaders < Flowjob::Actions::Base
      desc "Does not read"

      def call
      end
    end

    it 'explains what action is doing' do
      expect(Flowjob.explain(:populate)).to eq(
        "Populates context with needed data. It reads config, time_range, status"
      )

      expect(Flowjob.explain(:no_readers)).to eq("Does not read")
    end
  end
end
