class TargetAudienceController < ApplicationController
  unloadable

  def new
    @project = Project.find(params[:project_id])
    @assignables = @project.assignable_users
    @target_audience = TargetAudience.new
  end

  def create
    #FIXME não permitir incluir o mesmo usuário de novo (interno ou externo)
    @target_audience = TargetAudience.new
    @target_audience.communication_plan_id = params[:communication_plan_id]

    #se for usuário externo, tem e-mail e nome. Caso contrário, é só uma referência a um usuário já registrado
    if params[:external_user] == "1"
      @target_audience.external_user = true
      @target_audience.user_email = params[:user_email]
      @target_audience.user_name = params[:user_name]
    else
      @target_audience.external_user = false
      @target_audience.user_id = params[:user_id]
    end

    if @target_audience.save
      #TODO locale
      flash[:notice] = l(:notice_successful_update)
    else
      #TODO locale
      flash[:error] = 'Erro ao salvar.'
    end
    redirect_to :controller => 'communication_plan', :action => 'show'
  end

  def destroy
    @target_audience = TargetAudience.find(params[:id])
    @communication_plan = CommunicationPlan.find(params[:communication_plan_id])

    if @target_audience.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = l(:error_remove_recipient)
    end
    redirect_to :controller => 'communication_plan', :action => 'show'
  end

end
