class ShiftJob < ActiveRecord::Base

  # Relationships
  # ---------------------------
  
  belongs_to :job
  belongs_to :shift

  # Validations
  # ---------------------------
  
  validates_presence_of :shift_id, :job_id
  validates_associated :job, :shift
  
end
