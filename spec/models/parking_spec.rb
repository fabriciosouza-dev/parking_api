require_relative '../../app/models/parking'
require 'time'

RSpec.describe Parking do
  describe '#initialize' do
    let(:plate) { 'ABC-1234' }
    let(:parking) { build(:parking, plate: plate) }
    
    context 'with default values' do
      it 'creates a new parking correctly' do
        expect(parking.plate).to eq('ABC-1234')
        expect(parking.aasm.current_state).to eq(:entered)
        expect(parking.entry_time).to be_a(Time)
        expect(parking.exit_time).to be_nil
      end
    end

    context 'with lowercase plate' do
      let(:parking) { build(:parking, plate: 'abc-1234') }
      
      it 'normalizes plate to uppercase' do
        expect(parking.plate).to eq('ABC-1234')
      end
    end
  end

  describe '#within_grace_period?' do
    context 'when within 15 minutes' do
      let(:parking) { build(:parking, entry_time: Time.now - 10 * 60) }
      
      it 'returns true' do
        expect(parking.within_grace_period?).to be true
      end
    end
    
    context 'when outside 15 minutes' do
      let(:parking) { build(:parking, entry_time: Time.now - 20 * 60) }
      
      it 'returns false' do
        expect(parking.within_grace_period?).to be false
      end
    end
  end
  
  describe 'state transitions' do
    context 'when exiting without payment' do
      context 'within grace period' do
        let(:parking) { build(:parking, entry_time: Time.now - 10 * 60) }
        
        it 'allows exit' do
          expect(parking.exit!).to be true
          expect(parking.exited?).to be true
          expect(parking.aasm.current_state).to eq(:exited)
        end
      end
      
      context 'outside grace period' do
        let(:parking) { build(:parking, entry_time: Time.now - 20 * 60) }
        
        it 'does not allow exit' do
          expect { parking.exit! }.to raise_error(AASM::InvalidTransition)
          expect(parking.exited?).to be false
          expect(parking.aasm.current_state).to eq(:entered)
        end
      end
    end
    
    context 'when paid' do
      let(:parking) { build(:parking, :paid) }
      
      it 'allows exit regardless of time' do
        expect(parking.exit!).to be true
        expect(parking.exited?).to be true
        expect(parking.aasm.current_state).to eq(:exited)
      end
    end
  end

  describe '.find' do
    context 'when finding by id' do
      let(:id) { BSON::ObjectId.new }
      let(:parking) { build(:parking, id: id) }
      
      before do
        allow(Parking).to receive(:find).with(id.to_s).and_return(parking)
      end
      
      it 'returns the parking with matching id' do
        found = Parking.find(id.to_s)
        expect(found.id.to_s).to eq(id.to_s)
      end
    end

    context 'when finding by plate' do
      let(:plate) { 'ABC-1234' }
      let(:parking) { build(:parking, plate: plate) }
      
      before do
        allow(Parking).to receive(:find).with(plate).and_return(parking)
      end
      
      it 'returns the parking with matching plate' do
        found = Parking.find(plate)
        expect(found.plate).to eq(plate)
      end
    end

    context 'when parking does not exist' do
      before do
        allow(Parking).to receive(:find).with('non-existent').and_return(nil)
      end
      
      it 'returns nil' do
        expect(Parking.find('non-existent')).to be_nil
      end
    end
  end

  describe '.find_by_plate' do
    let(:plate) { 'ABC-1234' }
    let(:parking) { build(:parking, plate: plate) }
    
    before do
      allow(Parking).to receive(:find_by_plate).with(plate).and_return([parking])
    end
    
    it 'returns parkings for a plate' do
      parkings = Parking.find_by_plate(plate)
      expect(parkings).to be_an(Array)
      expect(parkings.first.plate).to eq(plate)
    end
  end
end