class PlateValidator
  def self.valid?(plate)
    return false if plate.nil? || plate.empty?
    
    normalized_plate = plate.upcase
    
    /^[A-Z]{3}-\d{4}$/.match?(normalized_plate)
  end
end