class TextingsController < ApplicationController
  before_action :find_project, only: [:show, :create]

  def index
    @textings = Texting.all
  end

  def show
    @texting_id = params[:id]
  end

  def create
    @texting = Texting.new(texting_params)
    @texting = @project.textings
    @texting = current_user.textings
    if @texting.save
      redirect_to projects_path
    else
      render 'texting/form'
    end
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  end

  def texting_params
    params.require(:texting).permit(:user_id, :project_id)
  end

end
