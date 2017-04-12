require 'spec_helper'

describe Flowjob::ContextWrapper do
  let(:data) do
    {
      name: 'John',
      age: 25,
      gender: 'male'
    }
  end

  let(:context) { described_class.new(data) }

  it 'denies access by default' do
    expect { context.name }.to be_forbidden
    expect { context.name = 'Ivan' }.to be_forbidden
  end

  context 'with whitelisted readers' do
    before do
      context.allow_readers(:name, :age)
    end

    it 'works' do
      expect(context.name).to eq 'John'
      expect(context.age).to eq 25
      expect { context.gender }.to be_forbidden
      expect { context.name = 'Ivan' }.to be_forbidden
    end
  end

  context 'with whitelisted writers' do
    before do
      context.allow_writers(:name, :age)
      context.allow_readers(:name)
    end

    it 'works' do
      expect { context.name = 'Ivan' }
        .to change(context, :name).from('John').to('Ivan')
      expect { context.age = 25 }.not_to raise_error
      expect { context.age }.to be_forbidden
    end
  end
end
