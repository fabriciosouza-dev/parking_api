require_relative 'base'

class ParkingExit < Base
  attr_reader :id, :parking

  def initialize(id, params = {})
    super(params)
    @id = id
    @parking = Parking.find(@id)
  end

  def process
    return false unless valid?
    
    @parking.instance_variable_set(:@exit_time, Time.now)
    @parking.instance_variable_set(:@left, true)
    @parking.save
    true
  end

  protected

  def validate
    if @parking.nil?
      add_error(:id, "Parking not found")
      return
    end

    unless @parking.paid
      add_error(:payment, "Parking not paid")
      return
    end

    if @parking.left
      add_error(:exit, "Vehicle already left")
    end
  end
end