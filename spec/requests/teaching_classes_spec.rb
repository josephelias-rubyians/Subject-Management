# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TeachingClasses', type: :request do
  let(:admin) { create_admin_user }
  let(:teacher) { create_user }
  let(:listing_url) { '/teaching_classes' }
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

    describe 'GET /teaching_classes as admin by giving a page number within total page number' do
      before do
        25.times { create_teaching_class }
        get listing_url, params: { page: 2 }, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 10 teaching classes for page 2 since per page teaching class is 10' do
        expect(JSON.parse(response.body)['data'].count).to eq(10)
      end
    end

    describe 'GET /teaching_classes as admin by giving a page number that exceeds total page number' do
      before do
        2.times { create_teaching_class }
        get listing_url, params: { page: 100 }, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should not return any teaching class' do
        expect(JSON.parse(response.body)['data'].count).to eq(0)
      end
    end

    describe 'Admin can create teaching class' do
      before do
        post '/teaching_classes',
             params: {
               'teaching_class': {
                 name: 'Class - 1'
               }
             }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('success.')
      end

      it 'should include the created teaching class info' do
        expect(JSON.parse(response.body)['data']['name']).to eq('Class - 1')
      end
    end

    describe 'When Admin create duplicate teaching class' do
      before do
        teaching_class = create_teaching_class
        post '/teaching_classes',
             params: {
               'teaching_class': {
                 name: teaching_class.name
               }
             }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Class already exists.')
      end
    end

    describe 'When Admin create case sensitive duplicate teaching class' do
      before do
        teaching_class = create_teaching_class
        post '/teaching_classes',
             params: {
               'teaching_class': {
                 name: teaching_class.name.upcase
               }
             }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Class already exists.')
      end
    end

    describe 'Admin can view teaching class' do
      before do
        3.times { create_teaching_class }
        get "/teaching_classes/#{TeachingClass.last.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return the teaching class info' do
        expect(JSON.parse(response.body)['data']['name']).to eq(TeachingClass.last.name)
      end
    end

    describe 'Admin can update any teaching class' do
      before do
        2.times { create_teaching_class }
        patch "/teaching_classes/#{TeachingClass.last.id}",
              params: {
                'teaching_class': {
                  name: 'Class-updated'
                }
              }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the class.')
      end

      it 'should include the updated teaching class info' do
        expect(JSON.parse(response.body)['data']['name']).to eq('Class-updated')
      end
    end

    describe 'Admin can delete any teaching class' do
      before do
        2.times { create_teaching_class }
        delete "/teaching_classes/#{TeachingClass.last.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully deleted the class.')
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

    describe 'GET /teaching_classes as teacher by giving a page number within total page number' do
      before do
        25.times { create_teaching_class }
        get listing_url, params: { page: 2 }, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 10 teaching class for page 2 since per page teaching class is 10' do
        expect(JSON.parse(response.body)['data'].count).to eq(10)
      end
    end

    describe 'GET /teaching_classes as teacher by giving a page number that exceeds total page number' do
      before do
        2.times { create_teaching_class }
        get listing_url, params: { page: 100 }, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should not return any teaching class' do
        expect(JSON.parse(response.body)['data'].count).to eq(0)
      end
    end

    describe 'Teacher cannot create teaching class' do
      before do
        post '/teaching_classes',
             params: {
               'teaching_class': {
                 name: 'Class - 1'
               }
             }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to create teaching class.')
      end
    end

    describe 'Teacher can view any teaching class' do
      before do
        3.times { create_teaching_class }
        get "/teaching_classes/#{TeachingClass.last.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return the teaching class info' do
        expect(JSON.parse(response.body)['data']['name']).to eq(TeachingClass.last.name)
      end
    end

    describe 'Teacher cannot update any teaching class' do
      before do
        2.times { create_teaching_class }
        patch "/teaching_classes/#{TeachingClass.last.id}",
              params: {
                'teaching_class': {
                  name: 'Class - updated'
                }
              }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to update teaching class.')
      end
    end

    describe 'Teacher cannot delete any teaching class' do
      before do
        2.times { create_teaching_class }
        delete "/teaching_classes/#{TeachingClass.last.id}", headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to delete teaching class.')
      end
    end
  end
  # Rspec for teacher ends here
end
