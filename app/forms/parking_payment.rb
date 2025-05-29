require_relative 'base'

class ParkingPayment < Base
  attr_reader :id, :parking

  def initialize(id, params = {})
    super(params)
    @id = id
    @parking = Parking.find(@id)
  end

  def process
    return false unless valid?
    
    @parking.pay!
    @parking.save
    true
  end

  protected

  def validate
    if @parking.nil?
      add_error(:id, "Parking not found")
      return
    end

    if @parking.paid? || @parking.exited?
      add_error(:payment, "Parking already paid")
    end
  end
end