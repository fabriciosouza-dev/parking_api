require 'time'
require 'bson'
require_relative '../concerns/plate_validatable'

class Parking
  include PlateValidatable
  
  attr_reader :id, :plate, :entry_time, :exit_time, :paid, :left

  COLLECTION_NAME = 'parkings'

  def initialize(plate, attributes = {})
    @id = attributes['_id'] || BSON::ObjectId.new
    @plate = plate.upcase
    @entry_time = attributes['entry_time'] || Time.now
    @exit_time = attributes['exit_time']
    @paid = attributes['paid'] || false
    @left = attributes['left'] || false
  end

  def save
    collection = Database.collection(COLLECTION_NAME)
    
    document = {
      _id: @id,
      plate: @plate,
      entry_time: @entry_time,
      paid: @paid,
      left: @left
    }
    
    document[:exit_time] = @exit_time if @exit_time
    
    result = collection.find(_id: @id).replace_one(document, upsert: true)
    self
  end

  def self.find(id)
    collection = Database.collection(COLLECTION_NAME)
    
    begin
      bson_id = BSON::ObjectId.from_string(id)
      document = collection.find(_id: bson_id).first
    rescue BSON::ObjectId::Invalid
      document = collection.find(plate: id.upcase).first
    end
    
    return nil unless document
    
    Parking.new(document['plate'], document)
  end

  def self.find_by_plate(plate)
    collection = Database.collection(COLLECTION_NAME)
    documents = collection.find(plate: plate.upcase).to_a
    
    documents.map do |doc|
      Parking.new(doc['plate'], doc)
    end
  end
end