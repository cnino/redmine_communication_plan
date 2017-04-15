class TargetAudienceController < ApplicationController
  unloadable

  def new
    logger.info ">>> (^_^) [TargetAudienceController#new]"

    #TODO logger
    params.each do |p|
      logger.info "[#{p.class}] #{p}"
    end

    @project = Project.find(params[:project_id])
    @assignables = @project.assignable_users

    @target_audience = TargetAudience.new
  end

  def create
    logger.info ">>> (^_^) [TargetAudienceController#create]"

    #TODO logger
    params.each do |p|
      logger.info "[#{p.class}] #{p}"
    end

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

    #FIXME if em uma linha?
    if @target_audience.save
      #TODO locale
      flash[:notice] = 'Configurações salvas.'
    else
      #TODO locale
      flash[:error] = 'Erro ao salvar.'
    end
    redirect_to :controller => 'communication_plan', :action => 'show'
  end

  def destroy
    logger.info ">>> (^_^) [TargetAudienceController#delete]"
    @target_audience = TargetAudience.find(params[:id])
    @communication_plan = CommunicationPlan.find(params[:communication_plan_id])

    #FIXME if em uma linha?
    if @target_audience.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = l(:error_remove_addressee)
    end
    redirect_to :controller => 'communication_plan', :action => 'show'
  end

end
