require_relative 'spec_helper'

RSpec.describe 'Parking API' do
  describe 'POST /parking' do
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    
    context 'with valid plate' do
      let(:parking) { build(:parking) }
      let(:request_body) { { plate: 'ABC-1234' }.to_json }
      
      before do
        allow_any_instance_of(ParkingEntry).to receive(:save).and_return(parking)
        post '/parking', request_body, headers
      end
      
      it 'creates a new parking entry' do
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to include('id')
      end
    end

    context 'with invalid plate' do
      let(:request_body) { { plate: 'INVALID' }.to_json }
      
      before do
        allow_any_instance_of(ParkingEntry).to receive(:valid?).and_return(false)
        allow_any_instance_of(ParkingEntry).to receive(:errors).and_return({ plate: ['Invalid plate format'] })
        post '/parking', request_body, headers
      end
      
      it 'returns an error' do
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include('error')
      end
    end
  end

  describe 'PUT /parking/:id/pay' do
    let(:parking_id) { BSON::ObjectId.new.to_s }
    
    context 'with valid id' do
      before do
        allow_any_instance_of(ParkingPayment).to receive(:process).and_return(true)
        put "/parking/#{parking_id}/pay"
      end
      
      it 'marks the parking as paid' do
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to include('message')
      end
    end

    context 'with already paid parking' do
      before do
        allow_any_instance_of(ParkingPayment).to receive(:process).and_return(false)
        allow_any_instance_of(ParkingPayment).to receive(:errors).and_return({ payment: ['Parking already paid'] })
        put "/parking/#{parking_id}/pay"
      end
      
      it 'returns an error' do
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include('error')
      end
    end

    context 'with invalid id' do
      before do
        allow_any_instance_of(ParkingPayment).to receive(:process).and_return(false)
        allow_any_instance_of(ParkingPayment).to receive(:errors).and_return({ id: ['Parking not found'] })
        put "/parking/non-existent-id/pay"
      end
      
      it 'returns not found' do
        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body)).to include('error')
      end
    end
  end

  describe 'PUT /parking/:id/out' do
    let(:parking_id) { BSON::ObjectId.new.to_s }
    
    context 'with valid id and paid parking' do
      before do
        allow_any_instance_of(ParkingExit).to receive(:process).and_return(true)
        put "/parking/#{parking_id}/out"
      end
      
      it 'marks the parking as left' do
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to include('message')
      end
    end

    context 'with unpaid parking' do
      before do
        allow_any_instance_of(ParkingExit).to receive(:process).and_return(false)
        allow_any_instance_of(ParkingExit).to receive(:errors).and_return({ payment: ['Parking not paid'] })
        put "/parking/#{parking_id}/out"
      end
      
      it 'returns an error' do
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include('error')
      end
    end

    context 'with already left parking' do
      before do
        allow_any_instance_of(ParkingExit).to receive(:process).and_return(false)
        allow_any_instance_of(ParkingExit).to receive(:errors).and_return({ exit: ['Vehicle already left'] })
        put "/parking/#{parking_id}/out"
      end
      
      it 'returns an error' do
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include('error')
      end
    end
  end

  describe 'GET /parking/:plate' do
    let(:plate) { 'ABC-1234' }
    
    context 'with valid plate' do
      let(:history) do
        [
          {
            id: BSON::ObjectId.new.to_s,
            time: '30 minutes',
            paid: true,
            left: true
          }
        ]
      end
      
      before do
        allow_any_instance_of(ParkingHistory).to receive(:fetch).and_return(history)
        get "/parking/#{plate}"
      end
      
      it 'returns parking history' do
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to be_an(Array)
      end
    end

    context 'with invalid plate' do
      before do
        allow_any_instance_of(ParkingHistory).to receive(:fetch).and_return(nil)
        allow_any_instance_of(ParkingHistory).to receive(:errors).and_return({ plate: ['Invalid plate format'] })
        get '/parking/INVALID'
      end
      
      it 'returns an error' do
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include('error')
      end
    end
  end
end