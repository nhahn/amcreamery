require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  # Check relationships
  should belong_to(:store)
  should belong_to(:employee)
  should have_many(:shifts)
  
  # Validation macros
  should validates_presence_of(:store_id)
  should validates_presence_of(:employee_id)
  should validates_presence_of(:start_date)
  should validates_presence_of(:pay_level)
  
  #Test Pay_level
  should allow_value(4).for(:pay_level)
  should_not allow_value(-1).for(:pay_level)
  should_not allow_value(8).for(:pay_level)
  should_not allow_value("test").for(:pay_level)

  context "Three stores, with five employees, each with an assignment to that store" do
    setup do
      @CMUStore = Factory.create(:store)
      @ShadyStore = Factory.create(:store, :name=> "Shadyside", :street => "300 Negley Ave", :zip => "15218")
      @OaklandStore = Factory.create(:store, :name=> "Oakland", :street => "200 5th Ave", :zip => "15222")
      @InactiveStore = Factory.create(:store, :name=> "Inactive", :active => false)

      @CMUManager = Factory.create(:employee, :role => "owner")
      @CMUEmployee = Factory.create(:employee, :first_name => "Jim", :last_name => "Jones", :date_of_birth => 8.years.ago)

      @ShadyManager = Factory.create(:employee, :role => "manager", :first_name => "Shady", :last_name => "Guy", :date_of_birth => 30.years.ago)

      @OaklandManager = Factory.create(:employee, :role => "owner", :first_name => "Joe", :last_name => "White", :date_of_birth => 40.years.ago)
      @OaklandEmployee = Factory.create(:employee, :first_name => "Tyler", :last_name => "Mansfield", :date_of_birth => 14.years.ago)

      @CMUManagerAssignment = Factory.create(:assignment, :store => @CMUStore, :employee => @CMUManager)
      @CMUEmployeeAssignment = Factory.create(:assignment, :store => @CMUStore, :employee => @CMUEmployee, :start_date =>5.days.ago)

      @ShadyManagerAssignment = Factory.create(:assignment, :store => @ShadyStore, :employee => @ShadyManager, :start_date => 1.year.ago)

      @OaklandManagerAssignment = Factory.create(:assignment, :store => @OaklandStore, :employee => @OaklandManager, :start_date => 2.years.ago)
      @OaklandEmployeeAssignment = Factory.create(:assignment, :store => @OaklandStore, :employee => @OaklandEmployee, :start_date => 4.months.ago)

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
    end
  end
end
