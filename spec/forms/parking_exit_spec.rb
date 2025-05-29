require_relative '../../app/forms/parking_exit'

RSpec.describe ParkingExit do
  describe '#valid?' do
    let(:form) { ParkingExit.new(id) }
    
    context 'when parking exists, is paid and not left' do
      let(:parking) { build(:parking, :paid) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
      end
      
      it 'returns true' do
        expect(form.valid?).to be true
      end
    end

    context 'when parking does not exist' do
      let(:id) { 'non-existent-id' }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(nil)
      end
      
      it 'returns false' do
        expect(form.valid?).to be false
        expect(form.errors[:id]).to include('Parking not found')
      end
    end

    context 'when parking is not paid' do
      let(:parking) { build(:parking) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
      end
      
      it 'returns false' do
        expect(form.valid?).to be false
        expect(form.errors[:payment]).to include('Parking not paid')
      end
    end

    context 'when parking has already left' do
      let(:parking) { build(:parking, :left) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
      end
      
      it 'returns false' do
        expect(form.valid?).to be false
        expect(form.errors[:exit]).to include('Vehicle already left')
      end
    end
  end

  describe '#process' do
    let(:form) { ParkingExit.new(id) }
    
    context 'when form is valid' do
      let(:parking) { build(:parking, :paid) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
      end
      
      it 'marks the parking as left' do
        expect(form.process).to be true
        expect(parking.left).to be true
      end
    end

    context 'when form is invalid' do
      let(:parking) { build(:parking) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
      end
      
      it 'returns false' do
        expect(form.process).to be false
      end
    end
  end
end