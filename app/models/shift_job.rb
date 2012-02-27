class ShiftJob < ActiveRecord::Base

  belongs_to :jobs
  belongs_to :shift

end
