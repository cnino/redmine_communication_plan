class CommunicationPlanController < ApplicationController
  unloadable

  #Exibe as configurações do plano de comunicação do projeto atual
  def show
    #O plano de comunicação está sempre dentro de um projeto
    @project = Project.find(params[:project_id])
    #uso a função assignable_users já definida em Project pelo Redmine
    @assignables = @project.assignable_users

    @communication_plan = CommunicationPlan.where(project_id: @project).first
    #se é a primeira vez que o plano está sendo acessado dentro do projeto, ainda não existe o objeto, então tenho que criá-lo
    if (@communication_plan.nil?)
      @communication_plan = CommunicationPlan.create(project: @project, periodicity: 1, start_date: Time.now)
    end

    #lista de opções de periodicidades
    #FIXME Colocar isso numa tabela para facilitar a configuração
    @periodicity_list = [[l(:label_weekly), 1], [l(:label_biweekly), 2], [l(:label_monthly), 3]]

    #lista de público-alvo configurado para este plano de comunicação
    @target_audience = TargetAudience.where(communication_plan: @communication_plan)

    #tenho que fazer uma verificação e inclusão de dados: usuários internos não estão com o nome e e-mail preenchidos
    @target_audience.each do |ta|
      unless ta.external_user
        @user_information = User.includes(:email_address).find(ta.user_id)
        ta.user_name = @user_information.firstname + " " + @user_information.lastname
        ta.user_email = @user_information.email_address.address
      end
    end

  end

  #Atualiza as configurações do plano de comunicação do usuário
  def update
    logger.info ">>>>>> update"
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first
    @communication_plan.user_id = params[:user_id]
    @communication_plan.periodicity = params[:periodicity]
    if params[:start_date].include? "-"
      @communication_plan.start_date = DateTime.strptime(params[:start_date], "%Y-%m-%d")
    else
      @communication_plan.start_date = DateTime.strptime(params[:start_date], l('date.formats.default'))
    end
    #@communication_plan.start_date = params[:start_date] == "" ? nil : DateTime.strptime(params[:start_date], l('date.formats.default'))
    @communication_plan.active = params[:active] == "1"
    @communication_plan.automatic_creation = params[:automatic_creation] == "1"

    if @communication_plan.save
      redirect_to action: "show", id: @communication_plan
      #TODO locale
      flash[:notice] = l(:notice_successful_update)
    else
      redirect_to action: "show", id: @communication_plan
      #TODO locale
      flash[:error] = 'Erro ao salvar.'
    end
  end

end
