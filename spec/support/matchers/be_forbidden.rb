RSpec::Matchers.define :be_forbidden do
  match do |block|
    begin
      block.call
      false
    rescue Flowjob::Errors::ForbiddenContextAccess
      true
    rescue
      false
    end
  end

  supports_block_expectations

  failure_message do |_|
    'expected to raise ForbiddenContextAccess error'
  end
end
