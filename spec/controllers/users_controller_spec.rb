# frozen_string_literal: true

require 'rails_helper'

describe UsersController, type: :request do
  let(:logout_url) { '/logout' }
  let(:admin) { create_admin_user }
  let(:teacher) { create_user }
  let(:listing_url) { '/users' }
  let(:change_password_admin) { "/users/#{admin.id}/update_password" }
  let(:change_password_teacher) { "/users/#{teacher.id}/update_password" }
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

    describe 'GET /users as admin' do
      before do
        2.times { create_user }
        get listing_url, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all user records' do
        expect(JSON.parse(response.body)['data'].count).to eq(User.count)
      end
    end

    describe 'Admin can view his profile' do
      before do
        get "/users/#{admin.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return the user info' do
        expect(JSON.parse(response.body)['data']['firstname']).to eq(admin.firstname)
        expect(JSON.parse(response.body)['data']['lastname']).to eq(admin.lastname)
        expect(JSON.parse(response.body)['data']['email']).to eq(admin.email)
      end
    end

    describe 'Admin can view other user profiles' do
      before do
        get "/users/#{teacher.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return the other user info' do
        expect(JSON.parse(response.body)['data']['firstname']).to eq(teacher.firstname)
        expect(JSON.parse(response.body)['data']['lastname']).to eq(teacher.lastname)
        expect(JSON.parse(response.body)['data']['email']).to eq(teacher.email)
      end
    end

    describe 'Admin can edit his profile' do
      before do
        patch "/users/#{admin.id}",
              params: {
                firstname: 'Joseph',
                lastname: 'Elias'
              }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end
    end

    describe 'Admin can edit other profiles' do
      before do
        patch "/users/#{teacher.id}",
              params: {
                firstname: 'Teacher',
                lastname: 'Tested'
              }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end
    end

    describe 'Admin can delete his profile' do
      before do
        delete "/users/#{admin.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully deleted the profile.')
      end
    end

    describe 'Admin can delete other profile' do
      before do
        delete "/users/#{teacher.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully deleted the profile.')
      end
    end

    describe 'Admin can change his password' do
      before do
        post change_password_admin,
             params: {
               'user':
               {
                 'password': 'password_new',
                 'password_confirmation': 'password_new',
                 'current_password': admin.password.to_s
               }
             }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully changed the password.')
      end
    end

    describe 'Password should contain minimum 6 characters' do
      before do
        post change_password_admin,
             params: {
               'user':
               {
                 'password': 'pass',
                 'password_confirmation': 'pass',
                 'current_password': admin.password.to_s
               }
             }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Minimum 6 chars required')
      end
    end

    describe 'When logging out' do
      it 'returns 200' do
        delete logout_url, headers: headers

        expect(response).to have_http_status(200)
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

    describe 'GET /users as teacher' do
      before do
        2.times { create_user }
        get listing_url, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns only current user profile' do
        expect(JSON.parse(response.body)['data']['attributes']).to include('id' => teacher.id)
      end

      it 'should not contain other user info' do
        expect(JSON.parse(response.body)['data']['attributes']).not_to include('id' => admin.id)
      end
    end

    describe 'Teacher can view his profile' do
      before do
        get "/users/#{teacher.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return the user info' do
        expect(JSON.parse(response.body)['data']['firstname']).to eq(teacher.firstname)
        expect(JSON.parse(response.body)['data']['lastname']).to eq(teacher.lastname)
        expect(JSON.parse(response.body)['data']['email']).to eq(teacher.email)
      end
    end

    describe 'Teacher cannot view other user profiles' do
      before do
        get "/users/#{admin.id}", headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to view the profile.')
      end
    end

    describe 'Teacher can edit his profile' do
      before do
        patch "/users/#{teacher.id}",
              params: {
                firstname: 'Joseph',
                lastname: 'Elias'
              }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end
    end

    describe 'Teacher cannot edit other profiles' do
      before do
        patch "/users/#{admin.id}",
              params: {
                firstname: 'Admin',
                lastname: 'Tested'
              }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to update the profile.')
      end
    end

    describe 'Teacher can delete his profile' do
      before do
        delete "/users/#{teacher.id}", headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully deleted the profile.')
      end
    end

    describe 'Teacher cannot delete other profile' do
      before do
        delete "/users/#{admin.id}", headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to delete the profile.')
      end
    end

    describe 'Teacher can change his password' do
      before do
        post change_password_teacher,
             params: {
               'user':
               {
                 'password': 'password_new',
                 'password_confirmation': 'password_new',
                 'current_password': teacher.password.to_s
               }
             }.to_json, headers: headers
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully changed the password.')
      end
    end

    describe 'New password and confirm password should match' do
      before do
        post change_password_teacher,
             params: {
               'user': {
                 'password': 'pass',
                 'password_confirmation': 'password',
                 'current_password': teacher.password.to_s
               }
             }.to_json, headers: headers
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('incorrect confirm password')
      end
    end
  end
  # Rspec for teacher ends here
end
