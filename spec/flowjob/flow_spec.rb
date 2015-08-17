require 'spec_helper'
require 'ostruct'

describe Flowjob::Flow do

  class Flowjob::Jobs::FillCommon < Flowjob::Jobs::Base
    context_reader :destination, :object

    def call
      destination.price = object[:price]
    end
  end

  class Flowjob::Jobs::FillAddress < Flowjob::Jobs::Base
    context_reader :destination, :object

    def call
      destination.address = object[:address]
    end
  end

  class Flowjob::Jobs::CheckArg < Flowjob::Jobs::Base
    context_reader :destination, :object

    def call(arg1, arg2)
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

  let(:context) do
    {
      destination: destination,
      object: object
    }
  end

  it "works" do
    Flowjob::Flow.run(context) do |flow|
      flow.fill_common
      flow.fill_address
    end
    expect(destination.price).to eq(7756)
    expect(destination.address).to eq('Kovalevskaya street')
  end

  it "has access to its context" do
    Flowjob::Flow.run(context) do |f|
      expect(f.context).to eq context
    end
  end

  it "passes args directly to call" do
    expect_any_instance_of(Flowjob::Jobs::CheckArg).
      to(receive :call).with("Foo", "Bar")

    Flowjob::Flow.run(context) do |f|
      f.check_arg("Foo", "Bar")
    end
  end

  context "job missing" do
    it "raises NoJobError" do
      expect {
        Flowjob::Flow.run(context) { |f| f.missing_job }
      }.to raise_error(Flowjob::Errors::NoJobError)
    end
  end

  context "internal exception" do
    class Flowjob::Jobs::BrokenJob < Flowjob::Jobs::Base
      def call
        raise "Custom error"
      end
    end

    it "passes original exception" do
      expect {
        Flowjob::Flow.run(context) { |f| f.broken_job }
      }.to raise_error "Custom error"
    end
  end

  context "Custom namespace" do
    module ::MyNamespace
      class FirstJob < Flowjob::Jobs::Base
        context_writer :first
        def call
          write_context(:first, true)
        end
      end

      class SecondJob < Flowjob::Jobs::Base
        context_writer :second
        def call
          write_context(:second, true)
        end
      end
    end

    it "works with specified namespace" do
      context = {}
      Flowjob::Flow.run(context, namespace: "MyNamespace") do |f|
        f.first_job
        f.second_job
      end
      expect(context).to eq({first: true, second: true})
    end
  end
end
