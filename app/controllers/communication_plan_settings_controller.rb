class CommunicationPlanSettingsController < ApplicationController
  unloadable

  def index
    logger.info ">>> (^_^) [CommunicationPlanSettingsController#index]"
    #A tela de configuração geral deve apresentar os seguintes dados: estados do projeto, sinalizadores, logotipo e lista de macro atividades
    @project_statuses = WorkperformanceReportStatus.all
    @flags = Flag.all
    @logo = CommunicationPlanSettings.where(parameter: "logo")
    puts ">> #{@logo}"
    @standard_activities = StandardMacroActivity.all
  end

  def update
    logger.info ">>> (^_^) [CommunicationPlanSettingsController#update]"
  end

end
