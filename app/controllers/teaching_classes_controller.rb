# frozen_string_literal: true

# TeachingClasses contoller for list, update, destroy etc
class TeachingClassesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_teaching_class_for_destroy, only: %i[destroy]
  before_action :find_teaching_class, only: %i[show update]

  def index
    @teaching_classes = TeachingClass.paginate(page: params[:page], per_page: 10)
    @total_pages = @teaching_classes.total_pages
    @total_entries = @teaching_classes.total_entries
    render json: {
      status: { code: 200, message: 'Success.' },
      meta: { total_pages: @total_pages, total_entries: @total_entries },
      data: TeachingClassSerializer.new(@teaching_classes).serializable_hash[:data]
    }
  end

  def show
    render_success_response('success.', true)
  end

  def create
    @teaching_class = TeachingClass.new(teaching_class_params)
    return unless authorize @teaching_class

    if @teaching_class.save
      render_success_response('success.', true)
    else
      render_failed_response(@teaching_class.errors[:name][0])
    end
  end

  def update
    return unless authorize @teaching_class

    begin
      @teaching_class.update(teaching_class_params)
      render_success_response('Successfully updated the class.', true)
    rescue Exception => e
      render_failed_response(e.message)
    end
  end

  def destroy
    return unless authorize @teaching_class

    @teaching_class.destroy
    render_success_response('Successfully deleted the class.', false)
  end

  private

  def teaching_class_params
    params.require(:teaching_class).permit(:name)
  end

  def find_teaching_class_for_destroy
    @teaching_class = TeachingClass.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_success_response('Successfully deleted the class.', false)
  end

  def find_teaching_class
    @teaching_class = TeachingClass.find(params[:id])
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
    resp['data'] = TeachingClassSerializer.new(@teaching_class).serializable_hash[:data][:attributes] if show_data
    render json: resp
  end
end
