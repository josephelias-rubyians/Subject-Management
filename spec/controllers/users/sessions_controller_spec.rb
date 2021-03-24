# frozen_string_literal: true

require 'rails_helper'

describe Users::SessionsController, type: :request do
  let(:user) { create_user }
  let(:login_url) { '/login' }
  let(:logout_url) { '/logout' }

  context 'When logging in' do
    before do
      login_with_api(user)
    end

    it 'returns a token' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'should return a success message' do
      expect(response.body).to include('Logged in successfully.')
    end

    it 'should return the user info' do
      expect(JSON.parse(response.body)['data']['firstname']).to eq(user.firstname)
      expect(JSON.parse(response.body)['data']['lastname']).to eq(user.lastname)
      expect(JSON.parse(response.body)['data']['email']).to eq(user.email)
    end

    it 'returns 200' do
      expect(response.status).to eq(200)
    end
  end

  context 'When password is missing' do
    before do
      post login_url, params: {
        user: {
          email: user.email,
          password: nil
        }
      }
    end

    it 'should return a error message' do
      expect(response.body).to include('Invalid Email or password.')
    end

    it 'returns 401' do
      expect(response.status).to eq(401)
    end
  end

  context 'When password is incorrect' do
    before do
      post login_url, params: {
        user: {
          email: user.email,
          password: 'incorrectpassword'
        }
      }
    end

    it 'should return a error message' do
      expect(response.body).to include('Invalid Email or password.')
    end

    it 'returns 401' do
      expect(response.status).to eq(401)
    end
  end

  context 'When logging out' do
    it 'returns 200' do
      delete logout_url

      expect(response).to have_http_status(200)
    end
  end
end
