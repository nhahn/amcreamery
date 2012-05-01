require 'test_helper'

class ShiftJobTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  should belong_to(:shift)
  should belong_to(:job)

  should validate_presence_of(:shift_id)
  should validate_presence_of(:job_id)

  test "test for a valid shift" do 
    @CMUStore = FactoryGirl.create(:store)
    @CMUEmployee = FactoryGirl.create(:employee, :first_name => "Jim", :last_name => "Jones", :date_of_birth => 15.years.ago)
    @CMUEmployeeAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUEmployee, :start_date =>5.days.ago, :pay_level => 3)

    @EmployeeShift = FactoryGirl.create(:shift, :assignment => @CMUEmployeeAssignment, :notes => "Fun shift")
    
  end
end
