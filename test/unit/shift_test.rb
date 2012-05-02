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
      @CMUStore = FactoryGirl.create(:store)
      @ShadyStore = FactoryGirl.create(:store, :name=> "Shadyside", :street => "300 Negley Ave", :zip => "15218")
      @OaklandStore = FactoryGirl.create(:store, :name=> "Oakland", :street => "200 5th Ave", :zip => "15222")

      @CMUManager = FactoryGirl.create(:employee, :role => "admin")
      @CMUEmployee = FactoryGirl.create(:employee, :first_name => "Jim", :last_name => "Jones", :date_of_birth => 15.years.ago)

      @ShadyManager = FactoryGirl.create(:employee, :role => "manager", :first_name => "Shady", :last_name => "Guy", :date_of_birth => 30.years.ago)

      @OaklandManager = FactoryGirl.create(:employee, :role => "admin", :first_name => "Joe", :last_name => "White", :date_of_birth => 40.years.ago)
      @OaklandEmployee = FactoryGirl.create(:employee, :first_name => "Tyler", :last_name => "Mansfield", :date_of_birth => 16.years.ago)

      @CMUManagerAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUManager)
      @CMUEmployeeAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUEmployee, :start_date =>5.days.ago, :pay_level => 3)

      @OaklandManagerPrevAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @OaklandManager, :start_date => 3.years.ago, :end_date => 2.years.ago)
      @CMUEmployeePrevAssignment = FactoryGirl.create(:assignment, :store => @ShadyStore, :employee => @CMUEmployee, :start_date => 1.year.ago, :end_date => 5.days.ago)
      
      @ShadyManagerAssignment = FactoryGirl.create(:assignment, :store => @ShadyStore, :employee => @ShadyManager, :start_date => 1.year.ago)

      @OaklandManagerAssignment = FactoryGirl.create(:assignment, :store => @OaklandStore, :employee => @OaklandManager, :start_date => 2.years.ago, :pay_level => 4)
      @OaklandEmployeeAssignment = FactoryGirl.create(:assignment, :store => @OaklandStore, :employee => @OaklandEmployee, :start_date => 4.months.ago)
      

  	  @ShadyManagerShift = FactoryGirl.create(:shift, :assignment => @ShadyManagerAssignment, :notes => "Fun shift")
      @ShadyManagerShift2 = FactoryGirl.create(:shift, :assignment => @ShadyManagerAssignment, :date => Date.yesterday, :start_time =>Time.parse("12:30"), :end_time => Time.parse("15:45") )
      @OaklandManagerShift = FactoryGirl.create(:shift, :assignment => @OaklandManagerAssignment, :date => Date.today)
      @OaklandManagerShift2 = FactoryGirl.create(:shift, :assignment => @OaklandManagerAssignment, :date => 5.days.ago, :start_time =>Time.parse("12:30"), :end_time => Time.parse("15:45") )
      @OaklandEmployeeShift = FactoryGirl.create(:shift, :assignment => @OaklandEmployeeAssignment, :date => 10.days.ago, :start_time =>Time.parse("8:30"), :end_time => Time.parse("12:45"))

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

    should "return hours for a shift" do
      assert_equal 3, @ShadyManagerShift.hours
    end
    
    should "return return false for incomplete shift" do
      assert !@ShadyManagerShift.completed?
    end

    should "sort shifts by date" do
      assert_equal "Tyler Mansfield", Shift.chronological.first.assignment.employee.proper_name
    end

    should "show upcomming shifts" do
      assert ["Shady Guy", "Joe White"].include? Shift.upcomming.chronological.first.assignment.employee.proper_name 
    end

    should "show today's shifts" do
      assert_equal "Joe White", Shift.today.chronological.first.assignment.employee.proper_name 
    end
	
    should "show shifts in the past" do
      assert_equal ["Joe White", "Shady Guy","Tyler Mansfield"], Shift.past.map{ |s| s.employee.proper_name}.sort
    end

    should "not allow inactive assignment for a new shift" do
  	  @ShadyShift = FactoryGirl.build(:shift, :assignment => @OaklandManagerPrevAssignment, :notes => "FALSE!")
      assert !@ShadyShift.valid?
    end

    should "not allow disassociated assignment for a shift" do
      @FakeShift = FactoryGirl.build(:assignment, :store => @CMUStore, :employee => @OaklandManager)
  	  @ShadyShift = FactoryGirl.build(:shift, :assignment => @FakeShift, :notes => "FALSE!")
      assert !@ShadyShift.valid?
    end

    should "not allow end time to be before the start time" do
      @Shift = FactoryGirl.build(:shift, :assignment => @OaklandManagerAssignment, :start_time => Time.now, :end_time => 1.hour.ago)
      assert !@Shift.valid?
    end

    should "return a DateTime object for a specific start time" do
      assert @ShadyManagerShift.starts_at.is_a? DateTime
      assert_equal @ShadyManagerShift.starts_at.hour, @ShadyManagerShift.start_time.hour
    end

    should "return a DateTime object for a specific end time" do
      assert @ShadyManagerShift.ends_at.is_a? DateTime
      assert_equal @ShadyManagerShift.ends_at.hour, @ShadyManagerShift.end_time.hour
    end

    end
  end
