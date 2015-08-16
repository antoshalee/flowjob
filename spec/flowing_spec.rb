require 'spec_helper'

describe Flowing do
  it 'has a version number' do
    expect(Flowing::VERSION).not_to be nil
  end

  describe ".explain" do
    class Flowing::Actions::Populate < Flowing::Actions::Base
      desc "Populates context with needed data"

      context_reader :config

      def call
        "I am populating"
      end
    end

    it 'explains what action is doing' do
      expect(Flowing.explain(:populate)).to eq("Populates context with needed data")
    end
  end
end
