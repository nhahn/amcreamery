class Shift < ActiveRecord::Base

  # Relationships
  # ----------------------

  belongs_to :assignment
  has_many :shift_jobs
  has_many :jobs, :through => :shift_jobs

  # Validations
  # ----------------------
  # Checks that date is infact a valid data
  validates_date :date
  # Checks that start time is a valid time
  validates_time :start_time
  # Checks that end time is a valid time after the start time
  validates_time :end_time, :after => :start_time
  #Checks that the assignment is a valid one
  validates_associated :assignment  
  # Checks that the assignment is current for an employee before creating a new shift
  validate :assignment_is_current
    
  # Scopes
  # ---------------------
  # returns the shifts for a particular store
  scope :for_store, lambda {|store| joins(:assignments).where('store_id = ?', store.id)}
  # returns the shifts for a particular employee
  scope :for_employee, lambda {|employee| joins(:assignments).where('employee_id = ?', employee.id)}
  # returns the upcomming shifts 
  scope :upcomming, lambda {where('date > ? OR (date = ? AND start_time >= ?)', Date.current, Date.current, Time.now.strftime("%H:%M:%S"))}
  # returns the shifts that are happening today
  scope :today, lambda {where('date = ?', Date.current)}
  
  def assignment_is_current
  	#get the assignment and see if it has a end_date
  	all_assignment_ids = Assignment.current.all.map{|a| a.id}
    unless all_assignment_ids.include?(self.assignment_id)
	  	errors.add(:assignment, "is not an active assignment in AMCreamery")
		  return false
	  end
	  return true
  end
  

end
