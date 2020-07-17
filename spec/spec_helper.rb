require 'rack/test'
require 'webmock/rspec'
require_relative '../github_status.rb'
WebMock.disable_net_connect!(allow_localhost: true)

module RspecHelper
  include Rack::Test::Methods
end

RSpec.configure do |config|
  config.include RspecHelper
end
