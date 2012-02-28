class Assignment < ActiveRecord::Base

  # ----------------------
  :before_create :end_previous_assignment

  # Relationships
  # ----------------------
  belongs_to :store
  belongs_to :employee
  has_many :shifts

  # Validations
  # ----------------------

  validates_presence_of :store_id, :employee_id, :start_date, :pay_level

  validates_inclusion_of :pay_level, :in => 1..6

  # Scope
  # ----------------------

  scope :current, where('end_date = ?', nil)

  scope :for_store, lambda {|store| where('store_id = ?', store.id) }

  scope :for_employee, lambda { |employee| where('employee_id = ?', employee.id) }

  scope :for_pay_level, lambda { |pay| joins(:employees).where('pay_level = ?', pay)}

  scope :by_pay_level, order('pay_level')

  scope :by_store, lambda { joins(:stores).order('stores.name') }

  def end_previous_assignment (employee)
  
  	previous_assignment = Assignment.find_by_employee_id(employee.id).where('end_date = ?', nil)
  	previous_assignment.end_date = Time.now
    
  end

end
