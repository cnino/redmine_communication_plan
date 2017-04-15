class CommunicationPlanController < ApplicationController
  unloadable

=begin
  def index
    logger.info ">>> (^_^) [CommunicationPlanController#index]"
    #O plano de comunicação está sempre dentro de um projeto
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #se é a primeira vez que o plano está sendo acessado dentro do projeto, ainda não existe o objeto
    #então, tenho que criá-lo
    if (@communication_plan == nil)
      @communication_plan = CommunicationPlan.create(project: @project, periodicity: 1)
    end

    #uso a função assignable_users já definida em Project pelo Redmine
    @assignables = @project.assignable_users
  end
=end

  def show
    logger.info ">>> (^_^) [CommunicationPlanController#show]"
    #O plano de comunicação está sempre dentro de um projeto
    @project = Project.find(params[:project_id])
    #uso a função assignable_users já definida em Project pelo Redmine
    @assignables = @project.assignable_users

    #se é a primeira vez que o plano está sendo acessado dentro do projeto, ainda não existe o objeto
    #então, tenho que criá-lo
    if (@communication_plan == nil)
      @communication_plan = CommunicationPlan.create(project: @project, periodicity: 1)
    else
      @communication_plan = CommunicationPlan.where(project_id: @project).first
    end

    #lista de opções de periodicidades
    #FIXME Colocar isso numa tabela para facilitar a configuração
    @periodicity_list = [["Semanal", 1], ["Quinzenal", 2], ["Mensal", 3]]

    #lista de público-alvo configurado para este plano de comunicação
    @target_audiences = TargetAudience.where(communication_plan: @communication_plan)

    #tenho que fazer uma verificação e inclusão de dados: usuários internos não estão com o nome e e-mail preenchidos
    @target_audiences.each do |person|
      unless person.external_user
        @user_information = User.includes(:email_address).find(person.user_id)
        #TODO Tem uma forma de pegar o nome completo?
        person.user_name = @user_information.firstname + " " + @user_information.lastname
        person.user_email = @user_information.email_address.address
      end
    end

  end

  def update
    logger.info ">>> (^_^) [CommunicationPlanController#update]"
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first
    @communication_plan.user_id = params[:user_id]
    @communication_plan.periodicity = params[:periodicity]
    #FIXME Verificar formato de data de acordo com preferências de idioma do usuário
    @communication_plan.start_date = params[:start_date] == "" ? nil : DateTime.strptime(params[:start_date], '%Y-%m-%d')
    @communication_plan.active = params[:active] == "1"
    @communication_plan.automatic_creation = params[:automatic_creation] == "1"

    #TODO logger
=begin
    params.each do |p|
      logger.info "[#{p.class}] #{p}"
    end
=end
    if @communication_plan.save
      redirect_to action: "show", id: @communication_plan
      #TODO locale
      flash[:notice] = 'Configurações salvas.'
    else
      redirect_to action: "show", id: @communication_plan
      #TODO locale
      flash[:error] = 'Erro ao salvar.'
    end
  end

end
