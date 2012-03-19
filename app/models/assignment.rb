class Assignment < ActiveRecord::Base

  # ----------------------
  before_create :end_previous_assignment

  # Relationships
  # ----------------------
  belongs_to :store
  belongs_to :employee
  has_many :shifts

  # Validations
  # ----------------------
  # check that all required fields are there
  validates_presence_of :store_id, :employee_id, :start_date, :pay_level
  validates_date :start_date 
  # check if the end_date is a valid date
  validates_date :end_date, :after => :start_date, :allow_nil => true, :allow_blank => true
  # we want the pay levels to be restricted to 1 through 6
  validates_inclusion_of :pay_level, :in => 1..6
  # check that store_id and employee_id are actually valid
  validates_associated :store, :employee
  # want to make sure that employee and store are active in the system before making a new assignment
  validate :employee_and_store_active

  # Scope
  # ----------------------
  # get a list of all the current assignments
  scope :current, where('end_date IS NULL')
  # gets a list of all assignments for a particular store
  scope :for_store, lambda {|store| where('store_id = ?', store.id) }
  # gets a list of all assignments for a particular employee
  scope :for_employee, lambda { |employee| where('employee_id = ?', employee.id) }
  # gets a list of all assignments for a particular pay level
  scope :for_pay_level, lambda { |pay| where('pay_level = ?', pay)}
  # get a sorted list of assignments by pay_level
  scope :by_pay_level, order('pay_level')
  # get a sorted list of assignments by store name
  scope :by_store, lambda { joins(:store).order('stores.name') }

  scope :past, where('end_date IS NOT NULL')
  scope :by_store, joins(:store).order('name')
  scope :chronological, order('start_date, end_date') 
 
  scope :for_role, lambda {|role| joins(:employee).where("role = ?", role) }

 
  def end_previous_assignment
    current_assignment = Employee.find(self.employee_id).current_assignment
    if current_assignment.nil?
      return true 
    else
      current_assignment.update_attribute(:end_date, self.start_date.to_date)
    end  
  end
  
  def employee_and_store_active
    all_employee_id = Employee.active.all.map{|e| e.id}
	  all_store_id = Store.active.all.map{|s| s.id}
    
    if !all_employee_id.include?(self.employee_id)
		  errors.add(:employee, "is not an active employee in AMCreamery")
		  return false
	  elsif !all_store_id.include?(self.store_id)
		  errors.add(:store, "is not an active store in AMCreamery")
		  return false
	  end
	  return true
  end

end
