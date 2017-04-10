require 'spec_helper'

describe Flowjob::Flow do
  describe '.context_writer' do
    let(:context_data) { {} }
    let(:context) { Flowjob::Context.new(context_data) }

    context 'job with context' do
      class JobWitContextWriter < Flowjob::Jobs::Base
        context_writer :status

        def call
          context.status = :ok
        end
      end

      subject { JobWitContextWriter.new(context).call }

      specify do
        subject
        expect(context.data[:status]).to eq(:ok)
      end
    end

    context 'job without context_writer' do
      class JobWithoutContextWriter < Flowjob::Jobs::Base
        def call
          context.status = :ok
        end
      end

      subject { JobWithoutContextWriter.new(context).call }

      it 'raises exception' do
        expect { subject }.to be_forbidden
      end
    end
  end
end
