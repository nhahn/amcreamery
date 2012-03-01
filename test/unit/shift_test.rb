require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  # Check relationships
  should belong_to(:assignment)
  should have_many(:jobs).through(:shift_jobs)
  
  context "Three stores, with five employees, each with an assignment to that store and two old assignments" do
    setup do
      @CMUStore = Factory.create(:store)
      @ShadyStore = Factory.create(:store, :name=> "Shadyside", :street => "300 Negley Ave", :zip => "15218")
      @OaklandStore = Factory.create(:store, :name=> "Oakland", :street => "200 5th Ave", :zip => "15222")

      @CMUManager = Factory.create(:employee, :role => "admin")
      @CMUEmployee = Factory.create(:employee, :first_name => "Jim", :last_name => "Jones", :date_of_birth => 8.years.ago)

      @ShadyManager = Factory.create(:employee, :role => "manager", :first_name => "Shady", :last_name => "Guy", :date_of_birth => 30.years.ago)

      @OaklandManager = Factory.create(:employee, :role => "admin", :first_name => "Joe", :last_name => "White", :date_of_birth => 40.years.ago)
      @OaklandEmployee = Factory.create(:employee, :first_name => "Tyler", :last_name => "Mansfield", :date_of_birth => 14.years.ago)

      @CMUManagerAssignment = Factory.create(:assignment, :store => @CMUStore, :employee => @CMUManager)
      @CMUEmployeeAssignment = Factory.create(:assignment, :store => @CMUStore, :employee => @CMUEmployee, :start_date =>5.days.ago, :pay_level => 3)

      @ShadyManagerAssignment = Factory.create(:assignment, :store => @ShadyStore, :employee => @ShadyManager, :start_date => 1.year.ago)

      @OaklandManagerAssignment = Factory.create(:assignment, :store => @OaklandStore, :employee => @OaklandManager, :start_date => 2.years.ago, :pay_level => 4)
      @OaklandEmployeeAssignment = Factory.create(:assignment, :store => @OaklandStore, :employee => @OaklandEmployee, :start_date => 4.months.ago)
      
      @OaklandManagerPrevAssignment = Factory.create(:assignment, :store => @CMUStore, :employee => @OaklandManager, :start_date => 3.years.ago, :end_date => 2.years.ago)
      @CMUEmployeePrevAssignment = Factory.create(:assignment, :store => @ShadyStore, :employee => @CMUEmployee, :start_date => 1.year.ago, :end_date => 5.days.ago)

  	  @ShadyManagerShift = Factory.create(:shift, :assignment => @ShadyManagerAssignment, :notes => "Fun shift")

    end

    teardown do
      @CMUStore.destroy
      @ShadyStore.destroy
      @OaklandStore.destroy
      @CMUManager.destroy
      @CMUEmployee.destroy
      @ShadyManager.destroy
      @OaklandManager.destroy
      @OaklandEmployee.destroy
      @CMUManagerAssignment.destroy
      @CMUEmployeeAssignment.destroy
      @ShadyManagerAssignment.destroy
      @OaklandManagerAssignment.destroy
      @OaklandEmployeeAssignment.destroy
      @OaklandManagerPrevAssignment.destroy
      @OaklandManagerPrevAssignment.destroy
  	  @ShadyManagerShift.destroy
    end
   
    

  end
end
