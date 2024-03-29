class Employee < ActiveRecord::Base

  # create a callback that will strip non-digits before saving to db
  before_save :reformat_phone_ssn
  # Relationships
  # -------------------------
  has_one  :user
  has_many :assignments
  has_many :stores, :through => :assignments
  has_many :shifts, :through => :assignments

  mount_uploader :photo, PhotoUploader

  accepts_nested_attributes_for :assignments, :reject_if => lambda {|assignment| assignment[:store_id].blank?}
  attr_accessor :assignments_attributes

  ROLES_LIST = [['Employee', 'employee'],['Manager', 'manager'],['Administrator', 'admin']]

  # Validataions
  # -------------------------
  # ensure we have all required fields, first_name, last_name, date_of_birth, role, and ssn
  validates_presence_of :first_name, :last_name, :date_of_birth, :role, :ssn
  # make sure the date_of_birth is valid aka before today
  validates_date :date_of_birth, :on_or_before => lambda { 14.years.ago }
  #ensure the ssn is the right length and has only dashes 
  validates_format_of :ssn, :with => /^\d{3}[- ]?\d{2}[- ]?\d{4}$/, :message => "should be 9 digits and delimited with dashes only"
  #ensure the phone number is the right length and formated the right way
  validates_format_of :phone, :with => /^(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})$/, :message => "should be 10 digits (area code needed) and delimited with dashes only", :allow_blank => true, :allow_nil => true
  #we want to limit possible roles to only employee, admin, and manager
  validates_inclusion_of :role, :in => %w[admin manager employee], :message => "is not an option" 
  #no one should have the same SSN....
  validates_uniqueness_of :ssn

  # Scope
  # -------------------------
  #list all employees that are under 18
  scope :younger_than_18, lambda { where('date_of_birth > ?', 18.years.ago.to_date)}
  #lists all employees that are 18 or older
  scope :is_18_or_older, lambda { where('date_of_birth <= ?', 18.years.ago.to_date)}
  #returns active employees in the system
  scope :active, where('active = ?', true)
  #returns incative employees in the system
  scope :inactive, where('active = ?', false)
  #returns regular employes in the system
  scope :regulars, where('role = ?', 'employee')
  #returns all managers in the system
  scope :managers, where('role = ?', 'manager')
  #returns all admins in the system
  scope :admins, where('role = ?', 'admin')
  #list employees in alphabetical order
  scope :alphabetical, order('last_name', 'first_name')
  # search for employees that find either by first or last name
  scope :search, lambda { |term| where('first_name LIKE ? OR last_name LIKE ?', "#{term}%", "#{term}%") }

  #get name in last, first format
  def name
    last_name + ", " + first_name
  end
  
  #get name in first, last format
  def proper_name
  	first_name + " " + last_name
  end

  #return the current assignment for an employee
  def current_assignment
    assignments.all.map{|a| a unless a.end_date != nil}.compact.first 
  end

  #true if employee is over 18
  def over_18?
    date_of_birth <= 18.years.ago.to_date 
  end
   
  #get the age of an employe
  def age
    Time.current.year - date_of_birth.year
  end

  # Callback code
  # ----------------------
   private
     # We need to strip non-digits before saving to db
     def reformat_phone_ssn
       phone = self.phone.to_s  # change to string in case input as all numbers        
       phone.gsub!(/[^0-9]/,"") # strip all non-digits
       self.phone = phone       # reset self.phone to new string
       ssn = self.ssn.to_s  # change to string in case input as all numbers        
       ssn.gsub!(/[^0-9]/,"") # strip all non-digits
       self.ssn = ssn       # reset ssn.phone to new string
      end   

end
