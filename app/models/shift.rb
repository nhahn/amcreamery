class Shift < ActiveRecord::Base

  belongs_to :assignment
  has_many :jobs, :through => :shift_jobs

end
