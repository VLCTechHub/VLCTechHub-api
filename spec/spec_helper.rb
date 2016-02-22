require 'rspec'
require 'rack/test'
require_relative '../boot'


RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.mock_with :rspec do |mocks|
    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelt names.
    mocks.verify_doubled_constant_names = true
  end
end


RSpec::Matchers.define :string_that_includes do |strings|
  match do |actual|
    strings.all? { |s| actual.include? s }
  end
end

Mail.defaults do
  delivery_method :test
end
