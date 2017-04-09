class Flag < ActiveRecord::Base
  unloadable

  has_many :workperformance_reports
end
