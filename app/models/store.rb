class Store < ActiveRecord::Base

  # create a callback that will strip non-digits before saving to db
  before_save :reformat_phone
#  before_validation :geoCode

STATES_LIST = [['Ohio', 'OH'],['Pennsylvania', 'PA'],['West Virginia', 'WV']]

  # Relationships
  # ---------------------
  
  has_many :assignments
  has_many :employees, :through => :assignments
  has_many :shifts, :through => :assignments

  # Validations
  # ---------------------
  # Check to see if all the required fields are present
  validates_presence_of :name, :street, :city
  # Makre sure we are only in the state of PA, OH, and WV
  validates_inclusion_of :state, :in => %w[PA OH WV], :message => "is not an option", :allow_nil =>true, :allow_blank=>true
  #Check zipcode length
  validates_format_of :zip, :with => /^\d{5}$/, :message => "should be a zipcode of 5 digits long"
  #Check phone format and length
  validates_format_of :phone, :with => /^(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})$/, :message => "should be 10 digits (area code needed) and delimited with dashes only", :allow_blank => true
  #Every store should have a unique name in the system
  validates_uniqueness_of :name


  # Scopes
  # ---------------------
  # list of stores in alphabetical order by name
  scope :alphabetical, order('name')
  # list of active stores
  scope :active, where('active = ?', true)
  # list of inactive stores
  scope :inactive, where('active = ?', false)
  # search for a store by name
  scope :search, lambda { |term| where('name LIKE ?', "#{term}%").order("name") }

  # Callback code
  # -----------------------------
   private
     # We need to strip non-digits before saving to db
     def reformat_phone
       phone = self.phone.to_s  # change to string in case input as all numbers       
       phone.gsub!(/[^0-9]/,"") # strip all non-digits
       self.phone = phone       # reset self.phone to new string
     end  

  private
   def geoCode 
    coord = Geokit::Geocoders::GoogleGeocoder.geocode "#{street}, #{zip}"
    if coord.success
      self.state = coord.state
      self.city = coord.city
      self.latitude, self.longitude = coord.ll.split(',')
    else
      errors.add_to_base("Error with geocoding")
    end
   end

   def create_map_link(zoom=13,width=400,height=400)
     "http://maps.google.com/maps/api/staticmap?center=#{lat},#{lon}&zoom=#{zoom}&size=#{width}x#{height}&maptype=roadmap&markers=color:red%red7Ccolor:red%7Clabel:!%7C#{lattitude},#{longitude}&sensor=false"
   end

end
