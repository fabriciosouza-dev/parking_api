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

    context 'when parking exists, is not paid but within grace period' do
      let(:parking) { build(:parking, entry_time: Time.now - 10 * 60) }
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

    context 'when parking is not paid and outside grace period' do
      let(:parking) { build(:parking, entry_time: Time.now - 20 * 60) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
      end
      
      it 'returns false' do
        expect(form.valid?).to be false
        expect(form.errors[:payment]).to include('Parking not paid and outside grace period')
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
      end
    end
  end

  describe '#process' do
    let(:form) { ParkingExit.new(id) }
    
    context 'when form is valid with paid parking' do
      let(:parking) { build(:parking, :paid) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
      end
      
      it 'marks the parking as left' do
        expect(form.process).to be true
        expect(parking.exited?).to be true
      end
    end
    
    context 'when form is valid with unpaid parking within grace period' do
      let(:parking) { build(:parking, entry_time: Time.now - 10 * 60) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
      end
      
      it 'marks the parking as left' do
        expect(form.process).to be true
        expect(parking.exited?).to be true
      end
    end

    context 'when form is invalid with unpaid parking outside grace period' do
      let(:parking) { build(:parking, entry_time: Time.now - 20 * 60) }
      let(:id) { parking.id.to_s }
      
      before do
        allow(Parking).to receive(:find).with(id).and_return(parking)
        allow(parking).to receive(:within_grace_period?).and_return(false)
        allow(parking).to receive(:exit!).and_raise(AASM::InvalidTransition)
      end
      
      it 'returns false' do
        expect(form.process).to be false
        expect(form.errors[:payment]).to include('Parking not paid and outside grace period')
      end
    end
  end
end