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
      @workperformance_reports = WorkperformanceReport.where(communication_plan: @communication_plan).includes(:user, :flag).order("start_period DESC")
    end
  end

  #exibe um relatório que já foi enviado (edição está bloqueada)
  def show
    logger.info ">>> (^_^) [WorkperformanceReportController#show]"
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #lista para autor
    #uso a função assignable_users já definida em Project pelo Redmine
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

    #gera a lista de público-alvo para exibir na tela
    @formatted_target_audience = get_formatted_target_audience

  end

  #atualiza os dados de um relatório
  def update
    logger.info ">>> (^_^) [WorkperformanceReportController#update]"
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #TODO logger
=begin
    logger.info ">>> Valores do params"
    params.each do |p|
      logger.info "   #{p.class}: #{p}"
    end
=end
    #pegando dados do form
    @workperformance_report = WorkperformanceReport.find(params[:id])
    @workperformance_report.user_id = params[:user_id]
    @workperformance_report.start_period = DateTime.strptime(params[:start_period], '%Y-%m-%d')
    @workperformance_report.end_period = DateTime.strptime(params[:end_period], '%Y-%m-%d')
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

    #verifico se devo enviar o relatório também
    logger.info ">>> Verificar se o relatório deve ser enviado..."
    unless params[:enviar].nil?
      logger.info ">>> Sim, devo enviar"
      @workperformance_report.send_date = Time.now
      @workperformance_report.sent_target_audience = get_formatted_target_audience

      logger.info ">>> O que temos aqui? [#{@workperformance_report.sent_target_audience}]"
    end


    if @workperformance_report.save
      redirect_to action: "show", id: @workperformance_report
      flash[:notice] = 'Relatório salvo.'
    else
      redirect_to action: "index"
      flash[:error] = 'Erro ao salvar.'
    end
  end

  #exibe formulário para criação de um novo relatório
  def new
    logger.info ">>> (^_^) [WorkperformanceReportController#new]"
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #não posso criar um novo relatório se ainda há um em aberto (não foi enviado ainda)
    unless WorkperformanceReport.where(send_date: nil).empty?
      #tenho um relatório pendente
      redirect_to action: "index"
      #TODO locale
      flash[:error] = 'Não é possível criar um novo relatório se houver um relatório pendente de envio.'
    else
      @workperformance_report = WorkperformanceReport.new

      #resgato o último relatório enviado deste plano de comunicação (se houver)
      @old_report = WorkperformanceReport.includes(:user, :flag, :issue_status).where(communication_plan: @communication_plan).order("send_date DESC").first

      if @old_report.nil?
        #mesmo se é um novo relatório, já possui as atividades padrão no cronograma para preenchimento
        @schedule_activities = StandardActivity.all.order(:order)
      else
        @workperformance_report = @old_report.dup
        #não há data de envio ainda
        @workperformance_report.send_date = nil
        #já altero o período do relatório (inicia um dia após o fim do período do anterior)
        @workperformance_report.start_period = @old_report.end_period+1.days
        #FIXME o período é configurável
        @workperformance_report.end_period = @workperformance_report.start_period+6.days
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
    end
  end

  #cria um novo relatório
  def create
    logger.info ">>> (^_^) [WorkperformanceReportController#create]"
    @project = Project.find(params[:project_id])
    @communication_plan = CommunicationPlan.where(project_id: @project).first

    #TODO logger
    params.each do |p|
      logger.info "[#{p.class}] #{p}"
    end

    @workperformance_report = WorkperformanceReport.new

    #pegando dados do form
    @workperformance_report.communication_plan = @communication_plan
    @workperformance_report.user_id = params[:user_id]
    @workperformance_report.start_period = DateTime.strptime(params[:start_period], '%Y-%m-%d')
    @workperformance_report.end_period = DateTime.strptime(params[:end_period], '%Y-%m-%d')
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
      #se o relatório foi criado com sucesso, crio também as atividades do cronograma, com as inforações do hash de activities
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

  private

  #retorna uma string de todo o público-alvo, no padrão "<nome> (<email>), <nome> (<email>)"
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


end
