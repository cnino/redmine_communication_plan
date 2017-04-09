# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

#configurações geral
get 'communication_plan_settings', :to => 'communication_plan_settings#index'
put 'communication_plan_settings', :to => 'communication_plan_settings#update'

#lista de relatórios geral

#configurações do projeto
#get 'communication_plan', :to => 'communication_plan#index'
match 'project/:project_id/communication_plan', :controller => 'communication_plan', :action => 'index', :via => :get

#lista de relatórios do projeto
get 'project/:project_id/workperformance_report', :to => 'workperformance_report#index'
get 'project/:project_id/workperformance_report/:id', :to => 'workperformance_report#show'
put 'project/:project_id/workperformance_report/:id', :to => 'workperformance_report#update'

#criação e edição de relatório, dentro do projeto

#visualização do relatório, fora do projeto
