class CommunicationPlan < ActiveRecord::Base
  unloadable

  has_many :target_audiences
  has_many :workperformance_reports
  belongs_to :project
  belongs_to :user

end
