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
      #uso a função assignable_users já definida em Project
      @assignables = @project.assignable_users

      #busco o relatório
      @workperformance_report = WorkperformanceReport.includes(:user, :flag, :workperformance_report_status).find(params[:id])

      #lista de estados possíveis para o relatório
      @report_statuses = WorkperformanceReportStatus.all.includes(:issue_status).map {|i| i.issue_status }

      #lista de flags
      @flags = Flag.all

      #lista de atividades do cronograma
      @schedule_activities = ScheduleActivity.where(workperformance_report: @workperformance_report).order(:order)
    end

    #atualiza os dados de um relatório
    def update
      logger.info ">>> (^_^) [WorkperformanceReportController#update]"
=begin
      logger.info ">>> Valores do params"
      params.each do |p|
        logger.info "   #{p.class}: #{p}"
      end
=end

      @workperformance_report = WorkperformanceReport.find(params[:id])
      @workperformance_report.user_id = params[:user_id]
      @workperformance_report.start_period = DateTime.strptime(params[:start_period], '%Y-%m-%d')
      @workperformance_report.end_period = DateTime.strptime(params[:end_period], '%Y-%m-%d')
      @workperformance_report.workperformance_report_status_id = params[:workperformance_report_status]
      @workperformance_report.flag_id = params[:flag]
      @workperformance_report.overall_objective = params[:overall_objective]
      @workperformance_report.status_description = params[:status_description]
      @workperformance_report.next_steps = params[:next_steps]
      @workperformance_report.risks = params[:risks]

      @schedule_activities = ScheduleActivity.where(workperformance_report: @workperformance_report)

      #lista de atividades
      @activities = Hash.new
      params.each do |p|
        if (p[0].include? "planned")
          @activity = @schedule_activities.select {|a| a.id == p[0].split('-')[1].to_i }.first
          @activity.update_attribute(:planned, p[1])
        elsif ((p[0].include? "accomplished"))
          @activity = @schedule_activities.select {|a| a.id == p[0].split('-')[1].to_i }.first
          @activity.update_attribute(:accomplished, p[1])
        end
      end


      if @workperformance_report.save
        redirect_to action: "show", id: @workperformance_report
        flash[:notice] = 'Relatório salvo.'
      else
        redirect_to action: "index"
      end

    end

end
