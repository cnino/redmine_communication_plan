#/bin/bash

#Models
$bundle exec ruby script/rails generate redmine_plugin_model communication_plan Communication_Plan active:boolean periodicity:integer start_date:datetime automatic_creation:boolean

$bundle exec ruby script/rails generate redmine_plugin_model communication_plan Target_Audience external_user:boolean user_email:string user_name:string

$bundle exec ruby script/rails generate redmine_plugin_model communication_plan Workperformance_Report start_period:datetime end_period:datetime overall_objective:text next_steps:text risks:text send_date:datetime

$bundle exec ruby script/rails generate redmine_plugin_model communication_plan Change_Request requester:string description:text opening_date:string situation:string

$bundle exec ruby script/rails generate redmine_plugin_model communication_plan Schedule_Activity version:integer order:integer activity:string planned:string accomplished:string

$bundle exec ruby script/rails generate redmine_plugin_model communication_plan Communication_Plan_Settings parameter:string value:string

$bundle exec ruby script/rails generate redmine_plugin_model communication_plan Standard_Macro_Activity order:integer title:string

$bundle exec ruby script/rails generate redmine_plugin_model communication_plan Flag name:string color:string

$bundle exec ruby script/rails generate redmine_plugin_model communication_plan <model_name> field:type Workperformance_Report_Status


#Controllers



rake redmine:plugins:migrate


