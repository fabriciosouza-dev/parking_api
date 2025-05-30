require_relative 'base'
require_relative '../models/parking'

class ParkingExit < Base
  attr_reader :id, :parking

  def initialize(id, params = {})
    super(params)
    @id = id
    @parking = Parking.find(@id)
  end

  def process
    return false unless valid?
    
    begin
      @parking.exit!
      @parking.save
      true
    rescue AASM::InvalidTransition
      add_error(:payment, "Parking not paid and outside grace period")
      false
    end
  end

  protected

  def validate
    if @parking.nil?
      add_error(:id, "Parking not found")
      return
    end

    # Verificamos se o estacionamento está no estado paid OU dentro do período de tolerância
    unless @parking.paid? || @parking.within_grace_period?
      add_error(:payment, "Parking not paid and outside grace period")
      return
    end

    if @parking.exited?
      add_error(:exit, "Vehicle already left")
      return
    end
  end
end