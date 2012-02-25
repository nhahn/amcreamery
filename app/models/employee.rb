class Employee < ActiveRecord::Base

  # Relationships
  # -------------------------
  has_one  :user
  has_many :assignments
  has_many :stores, :through => :assignment

  # Validataions
  # -------------------------

  validates_presence_of :first_name, :last_name, :date_of_birth, :role, :ssn

  validates_format_of :ssn, :with => /^\d{9}|\d{3}[-]\d{2}[-]\d{4}$/, :message => "should be 9 digits and delimited with
  dashes only"

  validates_format_of :phone, :with => /^(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})$/, :message => "should be 10 digits (area code needed) and delimited with dashes only"

  # Scope
  # -------------------------

  scope :younger_than_18, lambda {where('date_of_birth < ?', Time.current - 18.years)
}

  scope :18_or_older, lambda {where ('date_of_birth >= ?', Time.current - 18.years)}
  
  scope :active, where('active = ?', true)

  scope :inactive, where('active = ?', false)

  scope :regulars, where('role = ?', 'employee')

  scope :managers, where('role = ?', 'manager')

  scope :admins, where('role = ?', 'admins')

  scope :alphabetical, oder('last_name', 'first_name')

  def name
    last_name + ", " + first_name
  end

  def current_assignment
    joins(:assignments).where('end_date = NULL')
  end

  def over_18?
    date_of_birth < (Time.current - 18.years) 
  end

  def age
    (Time.current - date_of_birth).year
  end
end
