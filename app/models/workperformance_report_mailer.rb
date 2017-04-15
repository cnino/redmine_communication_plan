class WorkperformanceReportMailer < Mailer

  # Envia um e-mail com informações do relatório de andamento do projeto
  #
  # == Parameters:
  # recipients::
  #   Um array de objetos TargetAudience
  # project_name::
  #   Nome do projeto do relatório
  # report_data::
  #   Um objeto WorkperformanceReport (com include de :user, :flag e :issue_status)
  # report_schedule::
  #   Um array de objetos ScheduleActivity vinculados ao relatório
  #
  def send_workperformance_report (recipients, project_name, report_data, report_schedule)
    recipients.each do |r|
      mail to: r.user_email, subject: "Relatório de Acompanhamento - #{project_name} (#{format_date(report_data.start_period)} a #{format_date(report_data.end_period)})"
      @project_name = project_name
      @report_data = report_data
      @report_schedule = report_schedule
    end
  end

end
