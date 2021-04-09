# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserClassesSubjects', type: :request do
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

    describe 'Admin can add class and subjects to his/her own profile' do
      before do
        assign_subjects_and_class_to(admin, true, true)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end

      it 'should return the assigned class and subject id and its type' do
        data = json_data(admin)
        expect(JSON.parse(response.body)['data']).to eq(data)
      end
    end

    describe 'Admin can add class and subjects to other profile' do
      before do
        assign_subjects_and_class_to(create_user, true, true)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the profile.')
      end
    end

    describe 'Can assign class and subjects to a profile only if the given subject is added to corresponding class' do
      before do
        assign_subjects_and_class_to(create_user, true, false)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include("#{Subject.first.name} is not yet assigned to #{TeachingClass.first.name}")
      end
    end

    describe 'Can assign class and subjects to a profile only if the given subject is added as teaching subject of the profile' do
      before do
        assign_subjects_and_class_to(create_user, false, true)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include("#{Subject.first.name} is not yet marked as teaching subject of #{User.last.firstname}")
      end
    end

    describe 'Admin can remove class and subjects from his/her profile' do
      before do
        remove_subjects_and_class_from(admin)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully removed assigned subject and class from profile.')
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

    describe 'Teacher cannot have the permission to add class and subjects' do
      before do
        assign_subjects_and_class_to(teacher, true, true)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Only admin can assign subject and class to a user, contact your admin.')
      end
    end

    describe 'Teacher cannot have the permission to remove class and subjects' do
      before do
        remove_subjects_and_class_from(teacher)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Only admin can remove subject and class from user, contact your admin.')
      end
    end
  end
  # Rspec for teacher ends here

  def assign_subjects_and_class_to(user, pre_assign_user_sub, pre_assign_class_sub)
    # pre assigning subjects to user and class
    subject_ids = []
    2.times { subject_ids << create_subject.id }
    teaching_class = create_teaching_class
    user.subject_ids = subject_ids if pre_assign_user_sub
    teaching_class.subject_ids = subject_ids if pre_assign_class_sub

    post '/user_classes_subjects',
         params: {
           'user_classes_subject': {
             user_id: user.id,
             teaching_class_id: teaching_class.id,
             subject_id: subject_ids.first
           }
         }.to_json, headers: headers
  end

  def remove_subjects_and_class_from(user)
    # pre assigning subjects to user and class
    subject_ids = []
    2.times { subject_ids << create_subject.id }
    teaching_class = create_teaching_class
    user.subject_ids = subject_ids
    teaching_class.subject_ids = subject_ids
    # assigning subject and class for user
    rec = UserClassesSubject.create(user_id: user.id, subject_id: subject_ids.first, teaching_class_id: teaching_class.id)
    # calling delete api
    delete '/user_classes_subjects',
           params: {
             'user_classes_subject': {
               ids: rec.id.to_s,
             }
           }.to_json, headers: headers
  end

  def json_data(user)
    [{"id"=>UserClassesSubject.first.id.to_s,
      "type"=>"user_class_subject",
      "attributes"=>
       {"id"=>UserClassesSubject.first.id,
        "created_at"=>UserClassesSubject.first.created_at.as_json,
        "user"=>{"id"=>user.id, "first_name"=>user.firstname, "last_name"=>user.lastname, "created_at"=>user.created_at.as_json},
        "teaching_class"=>{"id"=>TeachingClass.first.id, "name"=>TeachingClass.first.name, "created_at"=>TeachingClass.first.created_at.as_json},
        "subject"=>{"id"=>Subject.first.id, "name"=>Subject.first.name, "created_at"=>Subject.first.created_at.as_json}}}]
  end
end
