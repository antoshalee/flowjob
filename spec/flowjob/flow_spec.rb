require 'spec_helper'
require 'ostruct'

describe Flowjob::Flow do
  class Flowjob::Jobs::FillCommon < Flowjob::Jobs::Base
    context_reader :destination, :object

    def call
      context.destination.price = context.object[:price]
    end
  end

  class Flowjob::Jobs::FillAddress < Flowjob::Jobs::Base
    context_reader :destination, :object

    def call
      context.destination.address = context.object[:address]
    end
  end

  class Flowjob::Jobs::CheckArg < Flowjob::Jobs::Base
    context_reader :destination, :object
    context_writer :result

    def call(result, _)
      context.result = result
    end
  end

  let(:object) do
    {
      price: 7756,
      area: 50,
      address: 'Kovalevskaya street'
    }
  end

  let(:destination) { OpenStruct.new }

  let(:context_data) do
    {
      destination: destination,
      object: object
    }
  end

  it 'works' do
    described_class.run(context_data) do |flow|
      flow.fill_common
      flow.fill_address
    end
    expect(destination.price).to eq(7756)
    expect(destination.address).to eq('Kovalevskaya street')
  end

  it 'has access to its context' do
    described_class.run(context_data) do |f|
      expect(f.context.data).to eq context_data
    end
  end

  it 'passes args directly to call' do
    expect_any_instance_of(Flowjob::Jobs::CheckArg)
      .to receive(:call).with('Foo', 'Bar')

    described_class.run(context_data) do |f|
      f.check_arg('Foo', 'Bar')
    end
  end

  it 'returns context' do
    result = described_class.run(context_data) do |f|
      f.check_arg('Foo', 'Bar')
    end
    expect(result).to be_instance_of(Hash)
    expect(result).to include(result: 'Foo')
  end

  context 'job missing' do
    it 'raises NoJobError' do
      expect { described_class.run(context_data) { |f| f.missing_job } }
        .to raise_error(Flowjob::Errors::NoJobError)
    end
  end

  context 'internal exception' do
    class Flowjob::Jobs::BrokenJob < Flowjob::Jobs::Base
      def call
        raise 'Custom error'
      end
    end

    it 'passes original exception' do
      expect { described_class.run(context_data) { |f| f.broken_job } }
        .to raise_error 'Custom error'
    end
  end

  context 'Custom namespace' do
    module MyNamespace
      class FirstJob < Flowjob::Jobs::Base
        context_writer :first

        def call
          context.first = true
        end
      end

      class SecondJob < Flowjob::Jobs::Base
        context_writer :second

        def call
          context.second = true
        end
      end
    end

    let(:context_data) { {} }

    subject do
      Flowjob::Flow.run(context_data, namespace: 'MyNamespace') do |f|
        f.first_job
        f.second_job
      end
    end

    it 'works with specified namespace' do
      expect { subject }.not_to raise_error
    end

    it 'changes result context' do
      expect(subject[:first]).to eq true
      expect(subject[:second]).to eq true
    end

    it 'doesnt mutate original context data' do
      subject
      expect(context_data).to eq({})
    end
  end
end
