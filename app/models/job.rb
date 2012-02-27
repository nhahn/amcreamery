class Job < ActiveRecord::Base

  # Relationships
  # ---------------------------

  has_many :assignment, :through => :shift_jobs 

end
