# Flowjob

Flowjob is a simple ruby library intended to help to organize your code. In a nutshell it allows to put pieces of logic of some long(and often spaghetti) process into separate classes (jobs).

Imagine some complex process consisted of many methods and variables:

```ruby
def import_from_xml(config, xml_source)
  raw_object        = parse(config, xml_source)
  sanitized_object  = sanitize(config, raw_object)
  product           = build_product(sanitized_object)
  save_result       = save_product(product)
  write_logs(config, xml_source, product, save_result)
end

def parse(source)
  # many lines of code
end

def sanitize(object)
  # many lines of code
end
...
def write_logs(config, xml_source, product, save_result)
  # many lines of code
end
```

Flowjob allows you to turn it to something like this:
```ruby
def import_from_xml(config, xml_source)
  Flowjob::Flow.run(config: config, xml_source: xml_source) do |flow|
    flow.parse
    flow.sanitize
    flow.save_product
    flow.write_logs
  end
end

class Parse < Flowjob::Jobs::Base
  context_reader :config, :xml_source
  context_writer :raw_object

  def call
    context.raw_object = do_something_with(context.xml_source)
  end
end

class Sanitize < Flowjob::Jobs::Base
  context_reader :config, :raw_object
  context_writer :sanitized_object

  def call
    # many lines of code
    context.sanitized_object = sanitize_somehow(context.raw_object)
  end
end

class BuildProduct < Flowjob::Jobs::Base
  context_reader :sanitized_object

  def call
    product = Product.build_somehow(context.sanitized_object)
  end
end

# etc
```
## Why?
1. Because it is much simplier to test. You can test each job in isolation. Just provide only required context as Hash object and write expectation what should appear inside it after job execution:

    ```ruby
      subject { MultipleByFourJob.new(input: 'two').call }

      specify do
        expect(subject.data[:output]).to eq('eight')
      end
    ```
2. This is a common situation when you need to access to previously defined data on the some step of the process. Example: writing original xml source into log after import is finished. No problem - just keep the source in global context during the whole process. You don't need to pass data from one method to another or keep it in tons of instance variables.

3. Now you can understand what the process really do step by step because of simple flow declaraton. All visual garbage is gone.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flowjob'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flowjob

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/flowjob.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
