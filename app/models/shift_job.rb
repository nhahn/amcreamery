class ShiftJob < ActiveRecord::Base

  # Relationships
  # ---------------------------

  attr_accessible :job_id, :shift_id, :shift_jobs_attributes

  belongs_to :job
  belongs_to :shift


  # Validations
  # ---------------------------
  
  validates_presence_of :shift_id, :job_id
  validates_associated :job, :shift
  validate :valid_shift

  def valid_shift
      return false if shift.nil?
    
    return shift.date < Date.current || (shift.date.to_s == Date.current.to_s && shift.end_time <= Time.now)
  end


end
