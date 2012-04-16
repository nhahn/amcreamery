class User < ActiveRecord::Base
  
  has_secure_password

  # Relationships
  # ----------------------
  belongs_to :employee
    
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :email, :password, :password_confirmation, :employee_id

  # Validations
  # ----------------------
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_associated :employee # Check that the employee is actually there
  validates_length_of :password, :minimum => 4, :allow_blank => true

  # login can be either username or email address
  
  def role?(authorized_role)
    return false if employee.nil?
    employee.role.downcase.to_sym == authorized_role
  end
  
  def self.authenticate(login, pass)
    find_by_email(login).try(:authenticate, pass)
  end

end



