require_relative '../../app/forms/base'

RSpec.describe Base do
  class TestForm < Base
    attr_reader :name, :age

    def initialize(params = {})
      super(params)
      @name = get_param(:name)
      @age = get_param(:age)
    end

    protected

    def validate
      if @name.nil? || @name.empty?
        add_error(:name, "Name is required")
      end

      if @age.nil? || @age <= 0
        add_error(:age, "Age must be positive")
      end
    end
  end

  describe '#valid?' do
    let(:form) { TestForm.new(params) }
    
    context 'when all validations pass' do
      let(:params) { {name: 'John', age: 30} }
      
      it 'returns true' do
        expect(form.valid?).to be true
      end
    end

    context 'when validations fail' do
      let(:params) { {name: '', age: -5} }
      
      it 'returns false and sets errors' do
        expect(form.valid?).to be false
        expect(form.errors[:name]).to include("Name is required")
        expect(form.errors[:age]).to include("Age must be positive")
      end
    end
  end

  describe '#get_param' do
    context 'with string keys' do
      let(:form) { TestForm.new('name' => 'John', 'age' => 30) }
      
      it 'retrieves parameters correctly' do
        expect(form.name).to eq('John')
        expect(form.age).to eq(30)
      end
    end

    context 'with symbol keys' do
      let(:form) { TestForm.new(name: 'John', age: 30) }
      
      it 'retrieves parameters correctly' do
        expect(form.name).to eq('John')
        expect(form.age).to eq(30)
      end
    end
  end
end