require 'sinatra/base'
require 'sinatra/json'
require 'json'
require_relative 'app/forms/parking_entry'
require_relative 'app/forms/parking_payment'
require_relative 'app/forms/parking_exit'
require_relative 'app/forms/parking_history'
require_relative 'config/database'

class ParkingAPI < Sinatra::Base
  configure do
    set :show_exceptions, false
    set :raise_errors, false
  end

  before do
    content_type :json
    if request.post? || request.put?
      begin
        request.body.rewind
        body_content = request.body.read
        @request_payload = JSON.parse(body_content) unless body_content.empty?
      rescue JSON::ParserError
        halt 400, json(error: 'Invalid JSON')
      end
    end
  end

  error do
    json(error: env['sinatra.error'].message)
  end

  post '/parking' do
    form = ParkingEntry.new(@request_payload)
    result = form.save
    
    if result
      status 201
      json(id: result.id.to_s)
    else
      status 422
      json(error: form.errors)
    end
  end

  put '/parking/:id/pay' do
    form = ParkingPayment.new(params[:id])
    
    if form.process
      json(message: 'Payment processed')
    else
      status form.errors[:id] ? 404 : 422
      json(error: form.errors)
    end
  end

  put '/parking/:id/out' do
    form = ParkingExit.new(params[:id])
    
    if form.process
      json(message: 'Vehicle left')
    else
      status form.errors[:id] ? 404 : 422
      json(error: form.errors)
    end
  end

  get '/parking/:plate' do
    form = ParkingHistory.new(params[:plate])
    history = form.fetch
    
    if history
      json(history)
    else
      status 422
      json(error: form.errors)
    end
  end

  not_found do
    json(error: 'Not Found')
  end
end