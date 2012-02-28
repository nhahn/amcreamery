class Job < ActiveRecord::Base

  # Relationships
  # ---------------------------

  has_many :assignment, :through => :shift_jobs 

  # Validations
  # ---------------------------

  validates_presence_of :name

  validates_uniqueness_of :name

  # Scopes
  # ---------------------------

  scope :active, where('active = ?', true)

  scope :inactive, where('active = ?', false)

  scope :alphabetical, order('name')

end
