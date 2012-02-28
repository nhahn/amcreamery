class Shift < ActiveRecord::Base

  # Relationships
  # ----------------------

  belongs_to :assignment
  has_many :jobs, :through => :shift_jobs

  # Validations
  # ----------------------
  
  validates_date :date

  validates_time :start_time

  validates_time :end_time, :after => :start_time

end
