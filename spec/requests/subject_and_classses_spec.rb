# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SubjectAndClassses', type: :request do
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

    describe 'Admin can assign subjects to class' do
      before do
        assign_subjects(false)
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully updated the class.')
      end

      it 'should return the assigned subjects' do
        expect(JSON.parse(response.body)['data'].size).to eq(2)
      end

      it 'should return the assigned subjects and class details and its type' do
        data = [{
          'id' => SubAndClass.first.id.to_s,
          'type' => 'subject_and_class',
          'attributes' =>
                  {
                    'id' => SubAndClass.first.id,
                    'created_at' => SubAndClass.first.created_at.as_json,
                    'subject' => { 'id' => Subject.first.id, 'name' => Subject.first.name.to_s,
                                   'created_at' => Subject.first.created_at.as_json },
                    'teaching_class' => { 'id' => TeachingClass.first.id, 'name' => TeachingClass.first.name.to_s,
                                          'created_at' => TeachingClass.first.created_at.as_json }
                  }
        },
                {
                  'id' => SubAndClass.last.id.to_s,
                  'type' => 'subject_and_class',
                  'attributes' =>
                  {
                    'id' => SubAndClass.last.id,
                    'created_at' => SubAndClass.last.created_at.as_json,
                    'subject' => { 'id' => Subject.last.id, 'name' => Subject.last.name.to_s,
                                   'created_at' => Subject.last.created_at.as_json },
                    'teaching_class' => { 'id' => TeachingClass.last.id, 'name' => TeachingClass.last.name.to_s,
                                          'created_at' => TeachingClass.last.created_at.as_json }
                  }
                }]
        expect(JSON.parse(response.body)['data']).to eq(data)
      end
    end

    describe 'When admin assigns already assigned subjects to a class' do
      before do
        assign_subjects(true)
      end

      it 'returns status 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('Subject has already been taken')
      end
    end

    describe 'Admin can remove subjects from the class' do
      before do
        remove_subjects
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'should return a success message' do
        expect(response.body).to include('Successfully removed subjects from the class.')
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

    describe 'When teacher assign subjects to class' do
      before do
        assign_subjects(false)
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to add subjects to the class.')
      end
    end

    describe 'When teacher trying to remove subjects from the class' do
      before do
        remove_subjects
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'should return a error message' do
        expect(response.body).to include('You are not allowed to delete subjects from class.')
      end
    end
  end
  # Rspec for teacher ends here

  def assign_subjects(pre_assign)
    teaching_class = create_teaching_class
    subject_ids = []
    2.times { subject_ids << create_subject.id }
    teaching_class.subject_ids = subject_ids if pre_assign
    post '/subject_and_classes',
         params: {
           'subject_and_class': {
             teaching_class_id: teaching_class.id,
             subject_ids: subject_ids.join(',')
           }
         }.to_json, headers: headers
  end

  def remove_subjects
    teaching_class = create_teaching_class
    subject_ids = []
    2.times { subject_ids << create_subject.id }
    teaching_class.subject_ids = subject_ids
    delete '/subject_and_classes',
           params: {
             'subject_and_class': {
               ids: SubAndClass.first.id.to_s
             }
           }.to_json, headers: headers
  end
end
