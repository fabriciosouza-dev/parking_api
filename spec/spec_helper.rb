require 'rack/test'
require 'rspec'
require 'factory_bot'
require 'faker'

ENV['RACK_ENV'] = 'test'
ENV['MONGODB_DATABASE'] = 'parking_api_test'

require_relative '../app'
require_relative 'factories'

module RSpecMixin
  include Rack::Test::Methods
  def app() ParkingAPI.new end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include FactoryBot::Syntax::Methods
  
  config.before(:each) do
    allow_any_instance_of(Parking).to receive(:save).and_return(self)
    
    allow(Parking).to receive(:find) do |id|
      if id == 'non-existent-id' || id == 'non-existent'
        nil
      else
        if id.to_s.include?('paid')
          build(:parking, :paid, id: BSON::ObjectId.from_string(id)) rescue build(:parking, :paid)
        elsif id.to_s.include?('left')
          build(:parking, :left, id: BSON::ObjectId.from_string(id)) rescue build(:parking, :left)
        else
          build(:parking, id: BSON::ObjectId.from_string(id)) rescue build(:parking)
        end
      end
    end
    
    allow(Parking).to receive(:history) do |plate|
      if plate =~ /^[A-Z]{3}-\d{4}$/
        [
          {
            id: BSON::ObjectId.new.to_s,
            time: '30 minutes',
            paid: true,
            left: true
          },
          {
            id: BSON::ObjectId.new.to_s,
            time: '10 minutes',
            paid: false,
            left: false
          }
        ]
      else
        []
      end
    end
  end
end
