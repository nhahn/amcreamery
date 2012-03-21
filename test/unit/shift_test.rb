require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  # Check relationships
  should belong_to(:assignment)
  should have_many(:jobs).through(:shift_jobs)
  should have_one(:employee).through(:assignment)
  should have_one(:store).through(:assignment)


  should validate_presence_of(:start_time)
  should validate_presence_of(:assignment_id)
  should validate_presence_of(:date)
  
  should_not allow_value("not a date").for(:end_time)
  should_not allow_value("still not a date").for(:date)

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

      @OaklandManagerPrevAssignment = Factory.create(:assignment, :store => @CMUStore, :employee => @OaklandManager, :start_date => 3.years.ago, :end_date => 2.years.ago)
      @CMUEmployeePrevAssignment = Factory.create(:assignment, :store => @ShadyStore, :employee => @CMUEmployee, :start_date => 1.year.ago, :end_date => 5.days.ago)
      
      @ShadyManagerAssignment = Factory.create(:assignment, :store => @ShadyStore, :employee => @ShadyManager, :start_date => 1.year.ago)

      @OaklandManagerAssignment = Factory.create(:assignment, :store => @OaklandStore, :employee => @OaklandManager, :start_date => 2.years.ago, :pay_level => 4)
      @OaklandEmployeeAssignment = Factory.create(:assignment, :store => @OaklandStore, :employee => @OaklandEmployee, :start_date => 4.months.ago)
      

  	  @ShadyManagerShift = Factory.create(:shift, :assignment => @ShadyManagerAssignment, :notes => "Fun shift")
      @ShadyManagerShift2 = Factory.create(:shift, :assignment => @ShadyManagerAssignment, :date => Date.yesterday, :start_time =>Time.parse("12:30"), :end_time => Time.parse("15:45") )
      @OaklandManagerShift = Factory.create(:shift, :assignment => @OaklandManagerAssignment, :date => Date.today)
      @OaklandManagerShift2 = Factory.create(:shift, :assignment => @OaklandManagerAssignment, :date => 5.days.ago, :start_time =>Time.parse("12:30"), :end_time => Time.parse("15:45") )
      @OaklandEmployeeShift = Factory.create(:shift, :assignment => @OaklandEmployeeAssignment, :date => 10.days.ago, :start_time =>Time.parse("8:30"), :end_time => Time.parse("12:45"))

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
      @OaklandManagerShift.destroy
      @OaklandManagerShift2.destroy
    end
   
    should "find the shifts for a particular store" do
      assert_equal 3, Shift.for_store(@OaklandStore).size
    end

    should "find shifts for a particular employee" do
      assert_equal 2, Shift.for_employee(@OaklandManager).size
    end

    should "sort shifts by date" do
      assert_equal "Tyler Mansfield", Shift.by_date.first.assignment.employee.proper_name
    end

    should "show upcomming shifts" do
      assert_equal "Joe White", Shift.upcomming.by_date.first.assignment.employee.proper_name 
    end

    should "show today's shifts" do
      assert_equal "Joe White", Shift.today.by_date.first.assignment.employee.proper_name 
    end
	
	should "show shifts in the pase" do
		assert_equal ["Shady Guy","Tyler Mansfield","Joe White"], Shift.past.employee.alphabetical.proper_name

    should "not allow inactive assignment for a new shift" do
  	  @ShadyShift = Factory.build(:shift, :assignment => @OaklandManagerPrevAssignment, :notes => "FALSE!")
      assert !@ShadyShift.valid?
    end

    should "not allow disassociated assignment for a shift" do
      @FakeShift = Factory.build(:assignment, :store => @CMUStore, :employee => @OaklandManager)
  	  @ShadyShift = Factory.build(:shift, :assignment => @FakeShift, :notes => "FALSE!")
      assert !@ShadyShift.valid?
    end

    should "not allow end time to be before the start time" do
      @Shift = Factory.build(:shift, :assignment => @OaklandManagerAssignment, :start_time => Time.now, :end_time => 1.hour.ago)
      assert !@Shift.valid?
    end

  end
end
