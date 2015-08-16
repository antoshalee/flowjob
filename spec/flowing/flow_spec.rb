require 'spec_helper'
require 'ostruct'

describe Flowing::Flow do

  class Flowing::Actions::FillCommon < Flowing::Actions::Base
    context_reader :destination, :object

    def call
      destination.price = object[:price]
    end
  end

  class Flowing::Actions::FillAddress < Flowing::Actions::Base
    context_reader :destination, :object

    def call
      destination.address = object[:address]
    end
  end

  class Flowing::Actions::CheckArg < Flowing::Actions::Base
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
    Flowing::Flow.run(context) do |flow|
      flow.fill_common
      flow.fill_address
    end
    expect(destination.price).to eq(7756)
    expect(destination.address).to eq('Kovalevskaya street')
  end

  it "has access to its context" do
    Flowing::Flow.run(context) do |f|
      expect(f.context).to eq context
    end
  end

  it "passes args directly to call" do
    expect_any_instance_of(Flowing::Actions::CheckArg).
      to(receive :call).with("Foo", "Bar")

    Flowing::Flow.run(context) do |f|
      f.check_arg("Foo", "Bar")
    end
  end

  context "action missing" do
    it "raises NoActionError" do
      expect {
        Flowing::Flow.run(context) { |f| f.missing_action }
      }.to raise_error(Flowing::Flow::NoActionError)
    end
  end

  context "internal exception" do
    class Flowing::Actions::BrokenAction < Flowing::Actions::Base
      def call
        raise "Custom error"
      end
    end

    it "passes original exception" do
      expect {
        Flowing::Flow.run(context) { |f| f.broken_action }
      }.to raise_error "Custom error"
    end
  end
end
