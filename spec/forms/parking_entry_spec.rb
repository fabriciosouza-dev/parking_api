require_relative '../../app/forms/parking_entry'

RSpec.describe ParkingEntry do
  describe '#valid?' do
    let(:form) { ParkingEntry.new(try(:params))}

    context 'when plate is valid' do
      let(:params) { {plate: 'ABC-1234'} }

      it 'returns true' do
        expect(form.valid?).to be true
      end
    end

    context 'when plate is invalid' do
      let(:params) { {plate: 'INVALID'} }

      it 'returns false for invalid format' do
        expect(form.valid?).to be false
        expect(form.errors[:plate]).to include('Invalid plate format. Must be AAA-9999')
      end

      context 'when plate is empty' do
        let(:params) { {plate: [nil, ''].sample} }

        it 'returns false for empty plate' do
          expect(form.valid?).to be false
          expect(form.errors[:plate]).to include('Plate is required')
        end
      end

      context 'when params is empty' do
        let(:params) { {} }
        
        it 'returns false for missing plate' do
          expect(form.valid?).to be false
          expect(form.errors[:plate]).to include('Plate is required')
        end
      end
    end
  end

  describe '#save' do
    let(:form) { ParkingEntry.new(try(:params)) }

    context 'when form is valid' do
      let(:params) { {plate: 'ABC-1234'} }
      let(:parking) { build(:parking, plate: 'ABC-1234') }
      
      before do
        allow(Parking).to receive(:new).and_return(parking)
      end
      
      it 'creates a new parking entry' do
        result = form.save
        expect(result).not_to be false
      end
    end

    context 'when form is invalid' do
      let(:params) { {plate: 'INVALID'} }
      
      it 'returns false' do
        expect(form.save).to be false
      end
    end
  end
end
