class WorkperformanceReport < ActiveRecord::Base
  unloadable

  belongs_to :communication_plan
  has_many :change_requests
  has_many :schedule_activities
  belongs_to :flag
  #FIXME Como garantir que, quando for excluir o estado no Redmine, eu bloqueie, se estiver em uso por algum relatório?
  belongs_to :issue_status
  belongs_to :user

end
