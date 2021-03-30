# frozen_string_literal: true

# Subjects contoller for list, update, destroy etc
class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_subject_for_destroy, only: %i[destroy]
  before_action :find_subject, only: %i[show update]

  def index
    @subjects = Subject.paginate(page: params[:page], per_page: 10)
    @total_pages = @subjects.total_pages
    @total_entries = @subjects.total_entries
    render json: {
      status: { code: 200, message: 'Success.' },
      meta: { total_pages: @total_pages, total_entries: @total_entries },
      data: SubjectSerializer.new(@subjects).serializable_hash[:data]
    }
  end

  def show
    render_success_response('success.', true)
  end

  def create
    @subject = Subject.new(subject_params)
    return unless authorize @subject
    
    if @subject.save
      render_success_response('success.', true)
    else
      render_failed_response(@subject.errors[:name][0])
    end
  end

  def update
    return unless authorize @subject

    begin
      @subject.update(subject_params)
      render_success_response('Successfully updated the subject.', true)
    rescue Exception => e
      render_failed_response(e.message)
    end
  end

  def destroy
    return unless authorize @subject

    @subject.destroy
    render_success_response('Successfully deleted the subject.', false)
  end

  private

  def subject_params
    params.require(:subject).permit(:name)
  end

  def find_subject_for_destroy
    @subject = Subject.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_success_response('Successfully deleted the subject.', false)
  end

  def find_subject
    @subject = Subject.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_failed_response("Record not found for ID #{params[:id]}")
  end

  def render_failed_response(msg)
    render json: {
      error: msg
    }, status: 400
  end

  def render_success_response(msg, show_data)
    resp = {}
    resp['status'] = { code: 200, message: msg }
    resp['data'] = SubjectSerializer.new(@subject).serializable_hash[:data][:attributes] if show_data
    render json: resp
  end
end
