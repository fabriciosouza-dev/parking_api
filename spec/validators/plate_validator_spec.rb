require_relative '../../app/validators/plate_validator'

RSpec.describe PlateValidator do
  describe '.valid?' do
    context 'when plate format is valid' do
      let(:uppercase_plate) { 'ABC-1234' }
      let(:lowercase_plate) { 'abc-1234' }
      let(:mixed_case_plate) { 'AbC-1234' }
      
      it 'returns true for uppercase plate' do
        expect(PlateValidator.valid?(uppercase_plate)).to be true
      end

      it 'returns true for lowercase plate' do
        expect(PlateValidator.valid?(lowercase_plate)).to be true
      end

      it 'returns true for mixed case plate' do
        expect(PlateValidator.valid?(mixed_case_plate)).to be true
      end
    end

    context 'when plate format is invalid' do
      let(:invalid_formats) do
        [
          'AB-1234',
          'ABCD-1234',
          'ABC-123',
          'ABC-12345',
          'ABC1234',
          '#####'
        ]
      end
      
      it 'returns false for nil plate' do
        expect(PlateValidator.valid?(nil)).to be false
      end

      it 'returns false for empty plate' do
        expect(PlateValidator.valid?('')).to be false
      end

      it 'returns false for plate with wrong format' do
        invalid_formats.each do |format|
          expect(PlateValidator.valid?(format)).to be false
        end
      end
    end
  end
end