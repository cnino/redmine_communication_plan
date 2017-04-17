class WorkperformanceReportController < ApplicationController
  unloadable

  #Lista de relatórios de um projeto
  def index
    @project = Project.find(params[:project_id])
    #todo projeto tem somente um plano de comunicação
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    @workperformance_reports = nil

    #lista de todos os relatórios deste plano de comunicação criados
    if (@communication_plan == nil)
      #significa que não há um plano ainda e, portanto, nenhum relatório foi gerado
      #TODO locale
      flash[:warning] = 'Plano de Comunicação não foi criado ainda.'
    else
      #lista dos relatórios deste projeto
      @workperformance_reports = WorkperformanceReport.where(communication_plan: @communication_plan).includes(:user, :flag).order("start_period DESC")

      #verifico se há um relatório pendente de envio. Caso positivo, ele ainda não possui valor ainda em sent_target_audience
      #coloco o dado do público-alvo configurado atualmente para o usuário visualizar na listagem
      if @workperformance_reports.size > 0 && @workperformance_reports[0].send_date.nil?
        @workperformance_reports[0].sent_target_audience = get_formatted_target_audience
      end
    end
  end

  #Exibe formulário para criação de um novo relatório
  def new
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #não posso criar um novo relatório se ainda há um em aberto (não foi enviado ainda)
    unless WorkperformanceReport.where(communication_plan: @communication_plan, send_date: nil).empty?
      #tenho um relatório pendente de envio
      redirect_to action: "index"
      flash[:error] = l(:text_cant_send_report)
    else
      @workperformance_report = WorkperformanceReport.new

      #resgato o último relatório enviado deste plano de comunicação (se houver)
      @old_report = WorkperformanceReport.includes(:user, :flag, :issue_status).where(communication_plan: @communication_plan).order("send_date DESC").first

      if @old_report.nil?
        #mesmo se é um novo relatório, já possui as atividades padrão no cronograma para preenchimento
        @schedule_activities = Array.new
        StandardMacroActivity.all.order(:order).each do |activity|
          @schedule_activities << ScheduleActivity.new(id: activity.id, title: activity.title)
        end
        #já há um autor default definido no plano de comunicação
        @workperformance_report.user = @communication_plan.user
        #também sei a data de início e fim do período (o que está configurado no plano de comunicação)
        @workperformance_report.start_period = @communication_plan.start_date
        @workperformance_report.end_period = get_end_date_with_periodicity
      else
        #copio as informações do relatório anterior para facilitar o preenchimento
        @workperformance_report = @old_report.dup
        #não há data de envio ainda
        @workperformance_report.send_date = nil
        #já altero o período do relatório (inicia um dia após o fim do período do anterior)
        @workperformance_report.start_period = @old_report.end_period+1.days
        @workperformance_report.end_period = get_end_date_with_periodicity
        #também devem ser pegas as atividades padrão para edição
        @schedule_activities = ScheduleActivity.where(workperformance_report: @old_report).order(:order)
      end

      #a lista de estados possíveis é definida pelo domínio de WorkperformanceReportStatus
      #entretanto, o relacionamento do WorkperformanceReport é direto com IssueStatus
      @report_statuses = WorkperformanceReportStatus.all.includes(:issue_status).map {|i| i.issue_status }

      #lista para autor, uso a função assignable_users já definida em Project pelo Redmine
      @assignables = @project.assignable_users

      #lista de flags existentes
      @flags = Flag.all

      #TODO locale
      #informações sobre periodicidades
      @period = 1 #sempre considero um período
      @periodicity_name = "Semana(s)"
      if @communication_plan.periodicity == 2
        @periodicity_name = "Quinzena(s)"
      elsif @communication_plan.periodicity == 3
        @periodicity_name = "Mês(es)"
      end
    end
  end

  #Cria um novo relatório
  def create
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first
    @workperformance_report = WorkperformanceReport.new

    logger.info ">>> Parâmetros:"
    params.each do |p, v|
      logger.info "#{p}: #{v}"
    end

    #dados do form
    @workperformance_report.communication_plan = @communication_plan
    @workperformance_report.user_id = params[:user_id]
    @workperformance_report.start_period = DateTime.strptime(params[:start_period], l('date.formats.default'))
    @workperformance_report.end_period = DateTime.strptime(params[:end_period], l('date.formats.default'))
    @workperformance_report.issue_status_id = params[:workperformance_report_status]
    @workperformance_report.flag_id = params[:flag]
    @workperformance_report.overall_objective = params[:overall_objective]
    @workperformance_report.status_description = params[:status_description]
    @workperformance_report.next_steps = params[:next_steps]
    @workperformance_report.risks = params[:risks]

    #lista de atividades já salvas para o relatório
    @schedule_activities = ScheduleActivity.where(workperformance_report: @workperformance_report)

    #atualização dos dados das atividades
    @activities = Hash.new
    params.each do |p|
      if (p[0].include? "planned")
        #crio um objeto ScheduleActivity e coloco lá a informação do planned
        @activity = ScheduleActivity.new(planned: p[1])
        #o padrão do nome dos campos é planned-id, uso o id para montar o hash
        @activities[p[0].split('-')[1]] = @activity

      elsif ((p[0].include? "accomplished"))
        #o padrão do nome dos campos é accomplished-id, devo extrair o id
        #busco o objeto no hash com esse mesmo id e atualizo a informação do accomplished
        @activity = @activities[p[0].split('-')[1]]
        @activity.accomplished = p[1]
      end
    end

    if @workperformance_report.save
      #se o relatório foi criado com sucesso, crio também as atividades do cronograma, com as informações do hash de activities
      @activities.each do |id, a|
        @activity_to_create = ScheduleActivity.find(id).dup
        @activity_to_create.planned = a.planned
        @activity_to_create.accomplished = a.accomplished
        @activity_to_create.workperformance_report = @workperformance_report
        @activity_to_create.save
      end

      redirect_to action: "show", id: @workperformance_report
      #TODO locale
      flash[:notice] = 'Relatório salvo.'
    else
      redirect_to action: "index"
      #TODO locale
      flash[:error] = 'Erro ao salvar.'
    end

  end

  #Exibe um relatório já salvo
  def show
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #lista para autor, uso a função assignable_users já definida em Project pelo Redmine
    @assignables = @project.assignable_users

    #busco o relatório
    @workperformance_report = WorkperformanceReport.includes(:user, :flag, :issue_status).find(params[:id])

    #FIXME show e new  possuem a mesma inicialização de informações, colocar num método só
    #A lista de estados possíveis é definida pelo domínio de WorkperformanceReportStatus
    #Entretanto, o relacionamento do WorkperformanceReport é direto com IssueStatus
    @report_statuses = WorkperformanceReportStatus.all.includes(:issue_status).map {|i| i.issue_status }

    #lista de flags existentes
    @flags = Flag.all

    #lista de atividades do cronograma
    @schedule_activities = ScheduleActivity.where(workperformance_report: @workperformance_report).order(:order)

    #TODO locale
    #informações sobre periodicidades
    @period = 1 #sempre considero um período
    @periodicity_name = "Semana(s)"
    if @communication_plan.periodicity == 2
      @periodicity_name = "Quinzena(s)"
    elsif @communication_plan.periodicity == 3
      @periodicity_name = "Mês(es)"
    end

    #gera a lista de público-alvo para exibir na tela
    @formatted_target_audience = get_formatted_target_audience
  end

  #atualiza os dados de um relatório
  def update
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #obtendo dados do form
    @workperformance_report = WorkperformanceReport.find(params[:id])
    @workperformance_report.user_id = params[:user_id]
    @workperformance_report.start_period = DateTime.strptime(params[:start_period], l('date.formats.default'))
    @workperformance_report.end_period = DateTime.strptime(params[:end_period], l('date.formats.default'))
    @workperformance_report.issue_status_id = params[:workperformance_report_status]
    @workperformance_report.flag_id = params[:flag]
    @workperformance_report.overall_objective = params[:overall_objective]
    @workperformance_report.status_description = params[:status_description]
    @workperformance_report.next_steps = params[:next_steps]
    @workperformance_report.risks = params[:risks]

    #lista de atividades já salvas para o relatório
    @schedule_activities = ScheduleActivity.where(workperformance_report: @workperformance_report)

    #atualização dos dados das atividades
    @activities = Hash.new
    params.each do |p|
      if (p[0].include? "planned")
        #o padrão do nome dos campos é planned-id, devo extrair o id
        @activity = @schedule_activities.select {|a| a.id == p[0].split('-')[1].to_i }.first
        @activity.update_attribute(:planned, p[1])
      elsif ((p[0].include? "accomplished"))
        #o padrão do nome dos campos é accomplished-id, devo extrair o id
        @activity = @schedule_activities.select {|a| a.id == p[0].split('-')[1].to_i }.first
        @activity.update_attribute(:accomplished, p[1])
      end
    end

    #verifico se devo enviar o relatório também por e-mail
    unless params[:enviar].nil?
      @workperformance_report.send_date = Time.now
      @workperformance_report.sent_target_audience = get_formatted_target_audience
    end

    if @workperformance_report.save
      #verifico se devo enviar o relatório também por e-mail
      unless params[:enviar].nil?
        #lista de destinatários para envio de e-mail
        @recipients = get_array_target_audience
        @recipients.each do |r|
          @email = WorkperformanceReportMailer.send_workperformance_report(r.user_email,
                                  @project.name,
                                  @workperformance_report,
                                  ScheduleActivity.where(workperformance_report: @workperformance_report))
          @email.deliver_now
        end
      end

      redirect_to action: "show", id: @workperformance_report
      #TODO locale
      flash[:notice] = params[:enviar].nil? ? 'Relatório salvo.' : 'Relatório enviado.'
    else
      redirect_to action: "index"
      #TODO locale
      flash[:error] = 'Erro ao salvar.'
    end
  end

  #Cancela um relatório que ainda não foi enviado (remove o registro)
  def cancel_report
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first
    @workperformance_report = WorkperformanceReport.find(params[:id])
    @schedule_activities = ScheduleActivity.where(workperformance_report: @workperformance_report)

    #garanto que o relatório não foi enviado
    if @workperformance_report.send_date.nil?
      #remover as tarefas do cronograma e o relatório
      @schedule_activities.destroy_all
      @workperformance_report.destroy
      #TODO locale
      flash[:notice] = "Relatório cancelado com sucesso."
    else
      #TODO locale
      flash[:error] = "Erro ao tentar cancelar relatório."
    end

    redirect_to action: "index"
  end


  private

  #Retorna uma string de todo o público-alvo, no padrão "<nome> (<email>), <nome> (<email>)"
  def get_formatted_target_audience
    #lista de público-alvo configurado para este plano de comunicação
    @target_audience = TargetAudience.where(communication_plan: @communication_plan)

    @formatted_list = Array.new

    #tenho que fazer uma verificação e inclusão de dados: usuários internos não estão com o nome e e-mail preenchidos
    @target_audience.each do |person|
      unless person.external_user
        @user_information = User.includes(:email_address).find(person.user_id)
        person.user_name = @user_information.firstname + " " + @user_information.lastname
        person.user_email = @user_information.email_address.address
      end
      @formatted_list << person.user_name + " (" + person.user_email + ")"
    end
    return @formatted_list.join(", ")
  end

  def get_array_target_audience
    #lista de público-alvo configurado para este plano de comunicação
    @target_audience = TargetAudience.where(communication_plan: @communication_plan)

    @array_target_audience = Array.new

    #tenho que fazer uma verificação e inclusão de dados: usuários internos não estão com o nome e e-mail preenchidos
    @target_audience.each do |person|
      unless person.external_user
        @user_information = User.includes(:email_address).find(person.user_id)
        person.user_name = @user_information.firstname + " " + @user_information.lastname
        person.user_email = @user_information.email_address.address
      end
      @array_target_audience << person
    end
    return @array_target_audience
  end

  #Retorna a data de fim o relatório, considerando a periodicidade configurada no plano de comunicação
  def get_end_date_with_periodicity
    @end_date_with_periodicity = @workperformance_report.start_period
    case @communication_plan.periodicity
    when 1 #Semanal (7 dias)
      @end_date_with_periodicity = @end_date_with_periodicity + 6.days
    when 2 #Quinzenal (14 dias)
      @end_date_with_periodicity = @end_date_with_periodicity + 13.days
    when 3 #Mensal
      @end_date_with_periodicity = @end_date_with_periodicity + 1.months - 1.days
    end
    @end_date_with_periodicity
  end

end
