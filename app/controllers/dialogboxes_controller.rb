class DialogboxesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_dialogbox, only: :show
  before_action :set_dialogbox_create_by_current_user, only: [:index, :show]
  before_action :set_current_user_projects, only: [:index, :show]

  def index
  end

  def show
    @dialogbox_id = params[:id]
    @current_user_id = current_user.id
    render :index
  end

  def create_message
    set_dialogbox_for_creating_message
    continue_dialog

    SendMessageJob.perform_later(@message)
  end

  private
  def set_current_user_projects
    @my_projects = current_user.projects
  end

  def set_dialogbox_create_by_current_user
    @sent_dialogboxes = current_user.dialogboxes
  end

  def dialogbox_params
    params.require(:dialogbox).permit(:project_id, :user_id, :project_owner_id)
  end

  def find_dialogbox
    @dialogbox = Dialogbox.find(params[:id])
  end

  def set_dialogbox_for_creating_message
    @dialogbox = Dialogbox.find(params[:message][:dialogbox])
  end

  def continue_dialog
    @message = current_user.messages.create(dialogbox: @dialogbox,
                                            user: current_user,
                                            content: params[:message][:content])
  end

  # def render_message
  #   ApplicationController.renderer.instance_variable_set(
  #   :@env, {
  #     "HTTP_HOST"=>"localhost:3000", 
  #     "HTTPS"=>"off", 
  #     "REQUEST_METHOD"=>"GET", 
  #     "SCRIPT_NAME"=>"",   
  #     "warden" => warden
  #   }
  # )
  # ApplicationController.render(partial: 'messages/message', locals: {message: @message})

  # end
end
