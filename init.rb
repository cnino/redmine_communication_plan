Redmine::Plugin.register :communication_plan do
  name 'Communication Plan plugin'
  author 'Cassia Nino'
  description 'A plugin for managing communication plans in projects.'
  version '0.0.1'
  url 'http://'
  author_url 'http://'

  #configurações gerais do plugin
  menu :admin_menu, :communication_plan_settings, { :controller => 'communication_plan_settings', :action => 'show'}, :caption => "Plano de Comunicação"

  #lista geral de relatórios

  #configurações do projeto
  permission :communication_plan, { :communication_plan => [:show, :update] }, :public => true
  menu :project_menu, :communication_plan, { :controller => 'communication_plan', :action => 'show' }, :caption => 'Plano de Comunicação', :after => :wiki, :param => :project_id

  #comunicação do projeto (lista de relatórios)
  permission :workperformance_report, { :workperformance_report => [:index, :show, :new] }, :public => true
  menu :project_menu, :workperformance_report, { :controller => 'workperformance_report', :action => 'index' }, :caption => 'Comunicação', :after => :activity, :param => :project_id

  #menu :project_menu, :workperformance_report, { :controller => 'workperformance_report', :action => 'index' }, :caption => 'Comunicação', :after => :activity, :param => :project_id

end
