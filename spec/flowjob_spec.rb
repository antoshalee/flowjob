require 'spec_helper'

describe Flowjob do
  it 'has a version number' do
    expect(Flowjob::VERSION).not_to be nil
  end

  describe '.explain' do
    class Flowjob::Jobs::Populate < Flowjob::Jobs::Base
      desc 'Does something'

      context_reader :config
      context_reader :time_range, :status

      def call
        'I am populating'
      end
    end

    class Flowjob::Jobs::NoReaders < Flowjob::Jobs::Base
      desc 'Does not read'

      def call
      end
    end

    it 'explains what job is doing' do
      expect(Flowjob.explain(:populate))
        .to eq('Does something. It reads config, time_range, status')

      expect(Flowjob.explain(:no_readers)).to eq('Does not read')
    end
  end
end
