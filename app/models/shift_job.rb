class ShiftJob < ActiveRecord::Base

  # Relationships
  # ---------------------------
  
  belongs_to :job
  belongs_to :shift

  # Validations
  # ---------------------------
  
  validates_associated :job, :shift
  
end
