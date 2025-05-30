require_relative 'base'
require_relative '../concerns/plate_validatable'
require_relative '../models/parking'

class ParkingEntry < Base
  include PlateValidatable
  
  attr_reader :plate

  def initialize(params = {})
    super(params)
    @plate = get_param(:plate)
  end

  def save
    return false unless valid?
    
    parking = Parking.new(@plate)
    parking.save
  end

  protected

  def validate
    if @plate.nil? || @plate.empty?
      add_error(:plate, "Plate is required")
      return
    end

    unless valid_plate?(@plate)
      add_error(:plate, "Invalid plate format. Must be AAA-9999")
    end
  end
end