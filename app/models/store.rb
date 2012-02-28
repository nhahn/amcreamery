class Store < ActiveRecord::Base

#  after_validation :fix_phone
  
  # Relationships
  # ---------------------
  
  has_many :assignments
  has_many :employees, :through => :assignments
  has_many :shifts, :through => :assignments

  # Validations
  # ---------------------
  # Check to see if all the required fields are present
  validates_presence_of :name, :street, :zip

  validates_inclusion_of :state, :in => %w[PA OH WV], :message => "is not an option", :allow_nil =>true, :allow_blank=>true

  validates_format_of :zip, :with => /^\d{5}$/, :message => "should be a zipcode of 5 digits long"
  
  validates_format_of :phone, :with => /^(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})$/, :message => "should be 10 digits (area code needed) and delimited with dashes only", :allow_blank => true

  validates_uniqueness_of :name


  # Scopes
  # ---------------------

  scope :alphabetical, order('name')

  scope :active, where('active = ?', true)

  scope :inactive, where('active = ?', false)

  private
  def fix_phone
    
    phone.gsub!(/[().\- ]/, //)
  end

end
