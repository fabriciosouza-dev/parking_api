require 'time'
require 'bson'
require 'aasm'
require_relative '../concerns/plate_validatable'

class Parking
  include PlateValidatable
  include AASM
  
  attr_reader :id, :plate, :entry_time, :exit_time

  COLLECTION_NAME = 'parkings'
  GRACE_PERIOD = 15 * 60
  
  aasm column: :state do
    state :entered, initial: true
    state :paid
    state :exited
    
    event :pay do
      transitions from: :entered, to: :paid
    end
    
    event :exit do
      transitions from: :paid, to: :exited
      transitions from: :entered, to: :exited, guard: :within_grace_period?
      after do
        @exit_time = Time.now
      end
    end
  end

  def initialize(plate, attributes = {})
    @id = attributes['_id'] || BSON::ObjectId.new
    @plate = plate.upcase
    @entry_time = attributes['entry_time'] || Time.now
    @exit_time = attributes['exit_time']
    @state = attributes['state'] || 'entered'

    aasm.current_state = @state.to_sym if @state
  end

  def save
    collection = Database.collection(COLLECTION_NAME)
    
    document = {
      _id: @id,
      plate: @plate,
      entry_time: @entry_time,
      state: aasm.current_state.to_s
    }
    
    document[:exit_time] = @exit_time if @exit_time
    
    result = collection.find(_id: @id).replace_one(document, upsert: true)
    self
  end

  def within_grace_period?
    (Time.now - @entry_time) <= GRACE_PERIOD
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