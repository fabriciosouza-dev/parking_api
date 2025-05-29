require_relative 'base'
require_relative '../concerns/plate_validatable'

class ParkingHistory < Base
  include PlateValidatable
  
  attr_reader :plate

  def initialize(plate, params = {})
    super(params)
    @plate = plate
  end

  def fetch
    return nil unless valid?
    
    parkings = Parking.find_by_plate(@plate)
    
    parkings.map do |parking|
      {
        id: parking.id.to_s,
        time: calculate_time_spent(parking),
        paid: parking.paid,
        left: parking.left
      }
    end
  end

  protected

  def validate
    unless valid_plate?(@plate)
      add_error(:plate, "Invalid plate format. Must be AAA-9999")
    end
  end
  
  def calculate_time_spent(parking)
    end_time = parking.exit_time || Time.now
    minutes = ((end_time - parking.entry_time) / 60).to_i
    
    if minutes < 60
      "#{minutes} minutes"
    else
      hours = minutes / 60
      remaining_minutes = minutes % 60
      "#{hours} hours and #{remaining_minutes} minutes"
    end
  end
end