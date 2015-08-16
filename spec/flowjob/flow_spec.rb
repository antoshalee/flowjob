require 'spec_helper'
require 'ostruct'

describe Flowjob::Flow do

  class Flowjob::Actions::FillCommon < Flowjob::Actions::Base
    context_reader :destination, :object

    def call
      destination.price = object[:price]
    end
  end

  class Flowjob::Actions::FillAddress < Flowjob::Actions::Base
    context_reader :destination, :object

    def call
      destination.address = object[:address]
    end
  end

  class Flowjob::Actions::CheckArg < Flowjob::Actions::Base
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
    expect_any_instance_of(Flowjob::Actions::CheckArg).
      to(receive :call).with("Foo", "Bar")

    Flowjob::Flow.run(context) do |f|
      f.check_arg("Foo", "Bar")
    end
  end

  context "action missing" do
    it "raises NoActionError" do
      expect {
        Flowjob::Flow.run(context) { |f| f.missing_action }
      }.to raise_error(Flowjob::Flow::NoActionError)
    end
  end

  context "internal exception" do
    class Flowjob::Actions::BrokenAction < Flowjob::Actions::Base
      def call
        raise "Custom error"
      end
    end

    it "passes original exception" do
      expect {
        Flowjob::Flow.run(context) { |f| f.broken_action }
      }.to raise_error "Custom error"
    end
  end

  context "Custom namespace" do
    module ::MyNamespace
      class FirstAction < Flowjob::Actions::Base
        def call
          context[:first] = true
        end
      end

      class SecondAction < Flowjob::Actions::Base
        def call
          context[:second] = true
        end
      end
    end

    it "works with specified namespace" do
      context = {}
      Flowjob::Flow.run(context, namespace: "MyNamespace") do |f|
        f.first_action
        f.second_action
      end
      expect(context).to eq({first: true, second: true})
    end
  end
end
