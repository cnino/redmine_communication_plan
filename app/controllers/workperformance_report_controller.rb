class WorkperformanceReportController < ApplicationController
  unloadable

  #lista de relatórios de um projeto
  def index
    @project = Project.find(params[:project_id])
    #todo projeto tem somente um plano de comunicação
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    @workperformance_reports = nil

    #lista de todos os relatórios deste plano de comunicação criados
    if (@communication_plan == nil)
      #significa que não há um plano ainda e, portanto, nenhum relatório foi gerado
      flash[:notice] = 'Plano de Comunicação não foi criado ainda.'
    else
      #lista dos relatórios deste projeto
      @workperformance_reports = WorkperformanceReport.where(communication_plan: @communication_plan).includes(:user, :flag)
    end
  end

    #exibe um relatório que já foi enviado (edição está bloqueada)
    def show
      logger.info ">>> (^_^) [WorkperformanceReportController#show]"
      @project = Project.find(params[:project_id])
      #@assignables = @project.members
      @assignables = @project.assignable_users

      logger.info ">>> assignables: #{@assignables}"
      logger.info ">>> assignables.collect: #{@assignables.collect}"

      logger.info ">>> params[:id] " + params[:id]
      @workperformance_report = WorkperformanceReport.includes(:user, :flag).find(params[:id])
      logger.info ">>> objeto report: " + @workperformance_report.id.to_s

    end

    #atualiza os dados de um relatório
    def update
      logger.info ">>> (^_^) [WorkperformanceReportController#update]"

      if @workperformance_report.save
        redirect_to action: "show", id: @workperformance_report
      else
        redirect_to action: "index"
      end

    end

end
