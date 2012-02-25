class Job < ActiveRecord::Base

  # Relationships
  # ---------------------------

  has_and_belongs_to_many :shift

end
