require_relative '../../app/forms/parking_history'

RSpec.describe ParkingHistory do
  describe '#valid?' do
    let(:form) { ParkingHistory.new(plate) }
    
    context 'when plate is valid' do
      let(:plate) { 'ABC-1234' }
      
      it 'returns true' do
        expect(form.valid?).to be true
      end
    end

    context 'when plate is invalid' do
      let(:plate) { 'INVALID' }
      
      it 'returns false' do
        expect(form.valid?).to be false
        expect(form.errors[:plate]).to include('Invalid plate format. Must be AAA-9999')
      end
    end
  end

  describe '#fetch' do
    let(:form) { ParkingHistory.new(plate) }
    
    context 'when form is valid' do
      let(:plate) { 'ABC-1234' }
      let(:parking1) { build(:parking, plate: plate, paid: true, left: true) }
      let(:parking2) { build(:parking, plate: plate, paid: false, left: false) }
      let(:expected_history) do
        [
          {
            id: parking1.id.to_s,
            time: '30 minutes',
            paid: true,
            left: true
          },
          {
            id: parking2.id.to_s,
            time: '10 minutes',
            paid: false,
            left: false
          }
        ]
      end
      
      before do
        allow(Parking).to receive(:find_by_plate).with(plate).and_return([parking1, parking2])
        allow_any_instance_of(ParkingHistory).to receive(:calculate_time_spent).with(parking1).and_return('30 minutes')
        allow_any_instance_of(ParkingHistory).to receive(:calculate_time_spent).with(parking2).and_return('10 minutes')
      end
      
      it 'returns parking history' do
        expect(form.fetch).to eq(expected_history)
      end
    end

    context 'when form is invalid' do
      let(:plate) { 'INVALID' }
      
      it 'returns nil' do
        expect(form.fetch).to be_nil
      end
    end
  end
end