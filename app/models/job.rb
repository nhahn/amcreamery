class Job < ActiveRecord::Base

  # Relationships
  # ---------------------------

  has_many :shift_jobs
  has_many :shifts, :through => :shift_jobs 

  # Validations
  # ---------------------------
  #Checks that a job has a name- the only thing required
  validates_presence_of :name
  #We want that name to be unique
  validates_uniqueness_of :name

  # Scopes
  # ---------------------------
  # Get all active jobs 
  scope :active, where('active = ?', true)
  # Get all inactive jobs
  scope :inactive, where('active = ?', false)
  # Get list of jobs in alphabetical order
  scope :alphabetical, order('name')

end
