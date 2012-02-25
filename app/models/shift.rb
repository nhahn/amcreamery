class Shift < ActiveRecord::Base

  belongs_to :assignment
  has_and_belongs_to_many :jobs

end
