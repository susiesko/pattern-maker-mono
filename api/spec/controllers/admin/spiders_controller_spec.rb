# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SpidersController, type: :controller do
  let(:admin_user) { create(:user, admin: true) }
  let(:regular_user) { create(:user, admin: false) }

  before do
    # Stub the available_spiders method directly instead of trying to stub Dir[]
    allow_any_instance_of(Admin::SpidersController).to receive(:available_spiders).and_return(['miyuki'])
  end

  describe 'GET #index' do
    context 'when user is an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(admin_user)
        get :index
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:success)
      end

      it 'returns a list of available spiders' do
        json_response = JSON.parse(response.body)
        expect(json_response['available_spiders']).to include('miyuki')
      end
    end

    context 'when user is not an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(regular_user)
        get :index
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #run' do
    context 'when user is an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(admin_user)
      end

      context 'with a valid spider name' do
        it 'enqueues a job to run the spider' do
          expect {
            post :run, params: { name: 'miyuki', max_pages: 10 }
          }.to have_enqueued_job(Catalog::RunSpiderJob).with('miyuki', { 'max_pages' => '10' })

          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to include('miyuki')
        end
      end

      context 'with an invalid spider name' do
        it 'returns a bad request status' do
          post :run, params: { name: 'invalid_spider' }

          expect(response).to have_http_status(:bad_request)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to include('Unknown spider')
        end
      end
    end

    context 'when user is not an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(regular_user)
        post :run, params: { name: 'miyuki' }
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
