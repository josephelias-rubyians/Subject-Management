# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserAndSubjects', type: :request do
  let(:admin) { create_admin_user }
  let(:teacher) { create_user }
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

    describe 'Admin can add subjects to his/her own profile' do
      before do
        assign_subjects_to(admin, false)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end

      it 'should return the assigned subjects' do
        expect(JSON.parse(response.body)['data']['relationships']['subjects']['data'].size).to eq(2)
      end

      it 'should return the assigned subjects id and its type' do
        expect(JSON.parse(response.body)['data']['relationships']['subjects']['data']).to include(
          { 'id' => Subject.first.id.to_s,
            'type' => 'subject' }, { 'id' => Subject.last.id.to_s, 'type' => 'subject' }
        )
      end
    end

    describe 'Admin can add subjects to other users' do
      before do
        assign_subjects_to(create_user, false)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end

      it 'should return the assigned subjects id and its type' do
        expect(JSON.parse(response.body)['data']['relationships']['subjects']['data']).to include(
          { 'id' => Subject.first.id.to_s,
            'type' => 'subject' }, { 'id' => Subject.last.id.to_s, 'type' => 'subject' }
        )
      end
    end

    describe 'When admin assigns already assigned subjects' do
      before do
        assign_subjects_to(admin, true)
      end

      it 'returns status 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Subject has already been taken')
      end
    end

    describe 'Admin can remove subjects from other users' do
      before do
        remove_subjects_from(create_user)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end

      it 'should removes all allocated subjects' do
        expect(JSON.parse(response.body)['data']['relationships']['subjects']['data']).to be_empty
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

    describe 'Teacher can add subjects to his profile' do
      before do
        assign_subjects_to(teacher, false)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end

      it 'should return the assigned subjects id and its type' do
        expect(JSON.parse(response.body)['data']['relationships']['subjects']['data']).to include(
          { 'id' => Subject.first.id.to_s, 'type' => 'subject' }, { 'id' => Subject.last.id.to_s, 'type' => 'subject' }
        )
      end
    end

    describe 'When teacher assigns already assigned subjects' do
      before do
        assign_subjects_to(teacher, true)
      end

      it 'returns status 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Subject has already been taken')
      end
    end

    describe 'Teacher can remove subjects from his/her profile' do
      before do
        remove_subjects_from(teacher)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end

      it 'should removes all allocated subjects' do
        expect(JSON.parse(response.body)['data']['relationships']['subjects']['data']).to be_empty
      end
    end

    describe 'Teacher cannot add subjects to other profile' do
      before do
        assign_subjects_to(create_user, false)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to add subjects to other user profile.')
      end
    end

    describe 'Teacher cannot remove subjects from other profile' do
      before do
        remove_subjects_from(create_user)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to delete subjects from other user profile.')
      end
    end
  end
  # Rspec for teacher ends here

  def assign_subjects_to(user, pre_assign)
    subject_ids = []
    2.times { subject_ids << create_subject.id }
    user.subject_ids = subject_ids if pre_assign
    post '/user_and_subjects',
         params: {
           'user_and_subject': {
             user_id: user.id,
             subject_ids: subject_ids.join(',')
           }
         }.to_json, headers: headers
  end

  def remove_subjects_from(user)
    subject_ids = []
    2.times { subject_ids << create_subject.id }
    user.subject_ids = subject_ids
    delete '/user_and_subjects',
           params: {
             'user_and_subject': {
               user_id: user.id,
               subject_ids: subject_ids.join(',')
             }
           }.to_json, headers: headers
  end
end
