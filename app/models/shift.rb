class Shift < ActiveRecord::Base

  before_save(:on => :create) do
    self.end_time = self.start_time + 3.hours unless self.start_time.nil?
  end

  # Relationships
  # ----------------------

  belongs_to :assignment
  has_many :shift_jobs, :dependent => :destroy
  has_many :jobs, :through => :shift_jobs
  has_one :employee, :through => :assignment
  has_one :store, :through => :assignment

  accepts_nested_attributes_for :shift_jobs


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
  #return all shifts that have been completed
  scope :completed, lambda { joins(:shift_jobs) }
  # returns shifts for a particular day
  scope :for_day, lambda {|day| where('date = ?', day)}
  # returns the upcomming shifts 
  scope :upcomming, lambda {where('date > ? OR (date = ? AND start_time >= ?)', Date.current.to_s, Date.current.to_s, Time.now.strftime("%H:%M:%S"))}
  # returns the shifts that are happening today
  scope :today, lambda {where('date = ?', Date.current)}
  # return shifts that were in the past (shifts that have an end time listed)
  scope :past, lambda {where('date < ?', Date.current)}
 
  scope :for_next_days, lambda {|num| where('date > ? and date <= ?', Date.current, Date.current + num.days)}

  scope :for_past_days, lambda {|num| where('date < ? and date >= ?', Date.current, Date.current - num.days)}
  
  scope :chronological, order('date').order('start_time ASC')
  
  scope :by_store, joins{:store}.order('name')
  
  scope :by_employee, joins{:employee}.order('last_name', 'first_name')
  
#  def end_time_is_valid
#    return true if self.end_time.nil?
#
#    if (Date.current > self.date || (Date.current == self.date && self.end_time <= Time.now))
#      return true
#    end
#
#    return false
#  end

  def completed?
    !self.shift_jobs.empty?
  end

  def hours
    self.end_time.hour - self.start_time.hour
  end

  def assignment_is_current
  	#get the assignment and see if it has a end_date
  	all_assignment_ids = Assignment.current.all.map{|a| a.id}
    unless all_assignment_ids.include?(self.assignment_id)
	  	errors.add(:assignment, "is not an active assignment in AMCreamery")
		  return false
	  end
	  return true
  end

  def starts_at
    DateTime.parse("#{date}T#{start_time.strftime("%H:%M:00")}")
  end 

  def ends_at
    DateTime.parse("#{date}T#{((end_time.nil?)? start_time + 3.hours : end_time).strftime("%H:%M:00")}")
  end 

end
