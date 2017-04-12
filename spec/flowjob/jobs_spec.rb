require 'spec_helper'

describe Flowjob::Flow do
  let(:context_data) { {} }
  let(:context) { Flowjob::ContextWrapper.new(context_data) }

  describe '.context_writer' do
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

  describe '.context_accessor' do
    class JobWithContextAccessor < Flowjob::Jobs::Base
      context_accessor :value

      def call
        context.value = context.value * 2
      end
    end

    let(:context_data) { { value: 10 } }

    subject { JobWithContextAccessor.new(context).call }

    specify do
      subject
      expect(context.data[:value]).to eq(20)
    end
  end
end
