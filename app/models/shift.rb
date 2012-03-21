class Shift < ActiveRecord::Base

  # Relationships
  # ----------------------

  belongs_to :assignment
  has_many :shift_jobs
  has_many :jobs, :through => :shift_jobs
  has_one :employee, :through => :assignment
  has_one :store, :through => :assignment

  # Validations
  # ----------------------
  validates_presence_of :start_time, :date, :assignment_id
  # Checks that date is infact a valid data
  validates_date :date
  # Checks that start time is a valid time
  validates_time :start_time
  # Checks that end time is a valid time after the start time and after the current time
  validates_time :end_time, :after => :start_time, :allow_blank => true, :allow_nil => true
  #Checks that the assignment is a valid one
  validates_associated :assignment  
  # Checks that the assignment is current for an employee before creating a new shift
  validate :assignment_is_current

  # Scopes
  # ---------------------
  # returns the shifts for a particular store
  scope :for_store, lambda {|store| joins(:assignment).where('store_id = ?', store.id)}
  # returns the shifts for a particular employee
  scope :for_employee, lambda {|employee| joins(:assignment).where('employee_id = ?', employee.id)}
  # returns shifts for a particular day
  scope :for_day, lambda {|day| where('date = ?', day)}
  # returns the upcomming shifts 
  scope :upcomming, lambda {where('date > ? OR (date = ? AND start_time >= ?)', Date.current, Date.current, Time.now.strftime("%H:%M:%S"))}
  # returns the shifts that are happening today
  scope :today, lambda {where('date = ?', Date.current)}
  # return shifts that were in the past (shifts that have an end time listed)
  scope :past, lambda {where('end_time IS NOT NULL')}
  
  scope :by_date, order('date')
  
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
