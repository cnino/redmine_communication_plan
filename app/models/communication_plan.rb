class CommunicationPlan < ActiveRecord::Base
  unloadable

  validates :start_date, presence: true

  has_many :target_audiences
  has_many :workperformance_reports
  belongs_to :project
  belongs_to :user

end
