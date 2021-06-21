require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl' ENV['RACK_ENV'] = 'test' require_relative '../server'

RSpec.describe Server do
# include Rack::Test::Methods include Capybara::DSL
before do
Capybara.app = Server.new
end
