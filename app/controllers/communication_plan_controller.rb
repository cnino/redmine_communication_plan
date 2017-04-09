class CommunicationPlanController < ApplicationController
  unloadable

  def index
    logger.info ">>> (^_^) [CommunicationPlanController#index]"
    #O plano de comunicação está sempre dentro de um projeto
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #se é a primeira vez que o plano está sendo acessado dentro do projeto, ainda não existe o objeto
    #então, tenho que criá-lo
    if (@communication_plan == nil)
      @communication_plan = CommunicationPlan.create(project: @project);
    end

  end

  def show
    logger.info ">>> (^_^) [CommunicationPlanController#show]"
    #O plano de comunicação está sempre dentro de um projeto
    @project = Project.find(params[:project_id])

  end

  def update
    logger.info ">>> (^_^) [CommunicationPlanController#update]"
  end

end
