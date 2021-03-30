# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  let(:user) { build_user }
  let(:existing_user) { create_user }
  let(:signup_url) { '/signup' }
  let(:params) do
    {
      user:{
        email: user.email,
        password: user.password,
        firstname: user.firstname,
        lastname: user.lastname,
        age: user.age
      }
    }
  end

  context 'When creating a new user' do
    before do
      post signup_url, params: params
    end

    it 'returns 200' do
      expect(response.status).to eq(200)
    end

    it 'returns a token' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns the user email' do
      expect(json['email']).to eq(user.email)
    end
  end

  context 'When an email already exists' do
    before do
      post signup_url, params: {
        user:{
          email: existing_user.email,
          password: existing_user.password,
          firstname: existing_user.firstname,
          lastname: existing_user.lastname,
          age: existing_user.age
        }
      }
    end

    it 'should return a error message' do
      expect(response.body).to include('has already been taken')
    end

    it 'returns 422' do
      expect(response.status).to eq(422)
    end
  end
end
