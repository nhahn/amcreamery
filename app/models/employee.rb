class Employee < ActiveRecord::Base

#  after_validation :fix_phone_ssn
  # Relationships
  # -------------------------
  has_one  :user
  has_many :assignments
  has_many :stores, :through => :assignments

  # Validataions
  # -------------------------

  validates_presence_of :first_name, :last_name, :date_of_birth, :role, :ssn

  validates_date :date_of_birth, :on_or_before => lambda { Date.current }
  
  validates_format_of :ssn, :with => /^\d{9}|\d{3}[-]\d{2}[-]\d{4}$/, :message => "should be 9 digits and delimited with dashes only"

  validates_format_of :phone, :with => /^(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})$/, :message => "should be 10 digits (area code needed) and delimited with dashes only"

  validates_format_of :role, :with => /employee|admin|manager/

  # Scope
  # -------------------------

  scope :younger_than_18, lambda { where('date_of_birth > ?', 18.years.ago.strftime("%Y-%m-%d"))}

  scope :is_18_or_older, lambda { where('date_of_birth <= ?', 18.years.ago.strftime("%Y-%m-%d"))}
  
  scope :active, where('active = ?', true)

  scope :inactive, where('active = ?', false)

  scope :regulars, where('role = ?', 'employee')

  scope :managers, where('role = ?', 'manager')

  scope :admins, where('role = ?', 'admin')

  scope :alphabetical, order('last_name', 'first_name')

  def name
    last_name + ", " + first_name
  end

  def current_assignment
    assignments.all.map{|a| a unless a.end_date != nil}.compact 
  end

  def over_18?
    date_of_birth <= 18.years.ago.strftime("%Y-%m-%d") 
  end

  def age
    Time.current.year - date_of_birth.year
  end

  private
  def fix_phone_ssn
    phone.gsub!(/[().\- ]/, //) 
    ssn.gsub!(/-/, //)
  end
end
