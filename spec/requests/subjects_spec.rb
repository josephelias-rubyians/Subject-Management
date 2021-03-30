# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Subjects", type: :request do
  let(:admin) { create_admin_user }
  let(:teacher) { create_user }
  let(:listing_url) { '/subjects' }
  let(:headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json'
    }
  end

  # Rspec for admin starts here
  describe 'when a admin user is logged in' do
    before do
      login_with_api(admin)
      @jwt_token = response.headers['Authorization'].split(' ').last
      headers['Authorization'] = "Bearer #{@jwt_token}"
    end

    it 'returns a token' do
      expect(response.headers['Authorization']).to be_present
    end

    describe 'GET /subjects as admin by giving a page number within total page number' do
      before do
        25.times { create_subject }
        get listing_url, params: { page: 2 }, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 10 subjects for page 2 since per page subjects is 10' do
        expect(JSON.parse(response.body)['data'].count).to eq(10)
      end
    end

    describe 'GET /subjects as admin by giving a page number that exceeds total page number' do
      before do
        2.times { create_subject }
        get listing_url, params: { page: 100 }, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should not return any subjects' do
        expect(JSON.parse(response.body)['data'].count).to eq(0)
      end
    end

    describe 'Admin can create subjects' do
      before do
        post '/subjects',
             params: {
               'subject': {
                 name: 'English'
               }
             }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('success.')
      end

      it 'should include the created subject info' do
        expect(JSON.parse(response.body)['data']['name']).to eq('English')
      end
    end

    describe 'When Admin create duplicate subject record' do
      before do
        subject = create_subject
        post '/subjects',
             params: {
               'subject': {
                 name: subject.name
               }
             }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Subject already exists.')
      end
    end

    describe 'When Admin create case sensitive duplicate subject record' do
      before do
        subject = create_subject
        post '/subjects',
             params: {
               'subject': {
                 name: subject.name.upcase
               }
             }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Subject already exists.')
      end
    end

    describe 'Admin can view any subjects' do
      before do
        3.times { create_subject }
        get "/subjects/#{Subject.last.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return the subject info' do
        expect(JSON.parse(response.body)['data']['name']).to eq(Subject.last.name)
      end
    end

    describe 'Admin can update any subjects' do
      before do
        2.times { create_subject }
        patch "/subjects/#{Subject.last.id}",
              params: {
                'subject': {
                  name: 'English-updated'
                }
              }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the subject.')
      end

      it 'should include the updated subject info' do
        expect(JSON.parse(response.body)['data']['name']).to eq('English-updated')
      end
    end

    describe 'Admin can delete any subjects' do
      before do
        2.times { create_subject }
        delete "/subjects/#{Subject.last.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully deleted the subject.')
      end
    end
  end
  # Rspec for admin ends here

  # Rspec for teacher starts here
  describe 'when a teacher user is logged in' do
    before do
      login_with_api(teacher)
      @jwt_token = response.headers['Authorization'].split(' ').last
      headers['Authorization'] = "Bearer #{@jwt_token}"
    end

    it 'returns a token' do
      expect(response.headers['Authorization']).to be_present
    end

    describe 'GET /subjects as teacher by giving a page number within total page number' do
      before do
        25.times { create_subject }
        get listing_url, params: { page: 2 }, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 10 subjects for page 2 since per page subjects is 10' do
        expect(JSON.parse(response.body)['data'].count).to eq(10)
      end
    end

    describe 'GET /subjects as teacher by giving a page number that exceeds total page number' do
      before do
        2.times { create_subject }
        get listing_url, params: { page: 100 }, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should not return any subjects' do
        expect(JSON.parse(response.body)['data'].count).to eq(0)
      end
    end

    describe 'Teacher cannot create subjects' do
      before do
        post '/subjects',
             params: {
               'subject': {
                 name: 'English'
               }
             }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to create subjects.')
      end
    end

    describe 'Teacher can view any subjects' do
      before do
        3.times { create_subject }
        get "/subjects/#{Subject.last.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return the subject info' do
        expect(JSON.parse(response.body)['data']['name']).to eq(Subject.last.name)
      end
    end

    describe 'Teacher cannot update any subjects' do
      before do
        2.times { create_subject }
        patch "/subjects/#{Subject.last.id}",
              params: {
                'subject': {
                  name: 'English'
                }
              }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to update the subject.')
      end
    end

    describe 'Teacher cannot delete any subjects' do
      before do
        2.times { create_subject }
        delete "/subjects/#{Subject.last.id}", headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to delete the subject.')
      end
    end
  end
  # Rspec for teacher ends here
end
