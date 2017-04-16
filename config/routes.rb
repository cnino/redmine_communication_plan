# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

#configurações geral
get 'communication_plan_settings', :to => 'communication_plan_settings#show'
put 'communication_plan_settings', :to => 'communication_plan_settings#update'

#lista de relatórios geral

#configurações do projeto
#get 'communication_plan', :to => 'communication_plan#index'
match 'projects/:project_id/communication_plan', :controller => 'communication_plan', :action => 'show', :via => :get
match 'projects/:project_id/communication_plan', :controller => 'communication_plan', :action => 'update', :via => :post

#match 'projects/:project_id/communication_plan/:communication_plan_id/target_audience/new', :controller => 'target_audience', :action => 'new', :via => :delete, :as => 'target_audicence'
get 'projects/:project_id/communication_plan/:communication_plan_id/target_audience/new', :to => 'target_audience#new'
post 'projects/:project_id/communication_plan/:communication_plan_id/target_audience', :to => 'target_audience#create'
delete 'projects/:project_id/communication_plan/:communication_plan_id/target_audience/:id', :to => 'target_audience#destroy'

#lista de relatórios do projeto
get 'projects/:project_id/workperformance_report', :to => 'workperformance_report#index'
get 'projects/:project_id/workperformance_report/new', :to => 'workperformance_report#new'
get 'projects/:project_id/workperformance_report/:id/cancel_report', :to => 'workperformance_report#cancel_report'
get 'projects/:project_id/workperformance_report/:id', :to => 'workperformance_report#show'
post 'projects/:project_id/workperformance_report/:id', :to => 'workperformance_report#update'
post 'projects/:project_id/workperformance_report', :to => 'workperformance_report#create'

#resources :projects do
# => resources :workperformance_reports
#end


#criação e edição de relatório, dentro do projeto

#visualização do relatório, fora do projeto
