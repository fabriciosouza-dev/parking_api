require 'json'
require_relative '../forms/parking_entry'
require_relative '../forms/parking_payment'
require_relative '../forms/parking_exit'
require_relative '../forms/parking_history'

class ParkingController
  def create(request)
    headers = { 'Content-Type' => 'application/json' }
    
    begin
      body = JSON.parse(request.body.read)
      
      form = ParkingEntry.new(body)
      result = form.save
      
      if result
        [201, headers, [{ id: result.id.to_s }.to_json]]
      else
        [422, headers, [{ error: form.errors }.to_json]]
      end
    rescue JSON::ParserError
      [400, headers, [{ error: 'Invalid JSON' }.to_json]]
    end
  end
  
  def pay(request, id)
    headers = { 'Content-Type' => 'application/json' }
    
    form = ParkingPayment.new(id)
    
    if form.process
      [200, headers, [{ message: 'Payment processed' }.to_json]]
    else
      status = form.errors[:id] ? 404 : 422
      [status, headers, [{ error: form.errors }.to_json]]
    end
  end
  
  def exit(request, id)
    headers = { 'Content-Type' => 'application/json' }
    
    form = ParkingExit.new(id)
    
    if form.process
      [200, headers, [{ message: 'Vehicle left' }.to_json]]
    else
      status = form.errors[:id] ? 404 : 422
      [status, headers, [{ error: form.errors }.to_json]]
    end
  end
  
  def history(request, plate)
    headers = { 'Content-Type' => 'application/json' }
    
    form = ParkingHistory.new(plate)
    history = form.fetch
    
    if history
      [200, headers, [history.to_json]]
    else
      [422, headers, [{ error: form.errors }.to_json]]
    end
  end
end
