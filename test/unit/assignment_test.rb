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
  should validate_presence_of(:store_id)
  should validate_presence_of(:employee_id)
  should validate_presence_of(:start_date)
  should validate_presence_of(:pay_level)
  
  #Test Pay_level
  should allow_value(4).for(:pay_level)
  should_not allow_value(-1).for(:pay_level)
  should_not allow_value(8).for(:pay_level)
  should_not allow_value("test").for(:pay_level)

  should_not allow_value("not a date").for(:start_date)

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

      @OaklandManagerPrevAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @OaklandManager, :start_date => 3.years.ago, :end_date => 2.years.ago)
      @CMUEmployeePrevAssignment = FactoryGirl.create(:assignment, :store => @ShadyStore, :employee => @CMUEmployee, :start_date => 1.year.ago, :end_date => 5.days.ago)
      
      @CMUManagerAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUManager)
      @CMUEmployeeAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUEmployee, :start_date =>5.days.ago, :pay_level => 3)

      @ShadyManagerAssignment = FactoryGirl.create(:assignment, :store => @ShadyStore, :employee => @ShadyManager, :start_date => 1.year.ago)

      @OaklandManagerAssignment = FactoryGirl.create(:assignment, :store => @OaklandStore, :employee => @OaklandManager, :start_date => 2.years.ago, :pay_level => 4)
      @OaklandEmployeeAssignment = FactoryGirl.create(:assignment, :store => @OaklandStore, :employee => @OaklandEmployee, :start_date => 4.months.ago)
      

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
    end

    should "not allow end_date to be before start_date" do
      @assignment = FactoryGirl.build(:assignment, :employee => @CMUEmployee, :store => @CMUStore, :end_date => 1.day.ago, :start_date => Date.today)
      assert !@assignment.valid?
    end

    should "return the current assignments" do
      assert_equal ["Guy", "Jones", "Mansfield", "Smith", "White"], Assignment.current.sort_by{|a| a.employee.last_name}.map{|a| a.employee.last_name}
    end

    should "return the assingments for a particular store" do
      assert_equal ["Guy", "Jones"], Assignment.for_store(@ShadyStore).map{|a| a.employee.last_name}.sort
    end

    should "return the assingments for a particular employee" do
      assert_equal ["CMU", "Shadyside"], Assignment.for_employee(@CMUEmployee).map{|a| a.store.name}.sort
    end

    should "return the assingments for a particular pay level" do
      assert_equal ["White"], Assignment.for_pay_level(4).map{|a| a.employee.last_name}.sort
    end

    should "end the previous assignment" do
      @newAssign = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUManager, :end_date => nil)
      @newAssign.end_previous_assignment
      @CMUManagerAssignment.reload
      assert @CMUManagerAssignment
    end

    should "return the assignment ordered by store" do
      assert_equal ["CMU", "Oakland"], Assignment.for_employee(@OaklandManager).by_store.map{|a| a.store.name}
    end
	
  	should "not allow validation of assignment with disassociated employee" do
	  	@employee = FactoryGirl.build(:employee, :first_name=>"Random", :last_name => "Person")
      bad_assignment = FactoryGirl.build(:assignment, :store => @ShadyStore, :employee => @employee)
  		assert !bad_assignment.valid?
  	end
	
  	should "not allow validation of assignment with disassociated store" do
  		@store = FactoryGirl.build(:store, :name=>"Random")
  		bad_assignment = FactoryGirl.build(:assignment, :store => @store, :employee => @CMUEmployee)
  		assert !bad_assignment.valid?
  	end

    should "now allow an assignment to be created with an inactive store" do
      @store = FactoryGirl.create(:store, :name => "Random", :active => false)
      bad_assignment = FactoryGirl.build(:assignment, :store => @store, :employee => @CMUEmployee)
      assert !bad_assignment.valid?
      @store.destroy
    end

    should "now allow an assignment to be created with an inactive employee" do
      @employee = FactoryGirl.create(:employee, :first_name => "Random", :active => false)
      bad_assignment = FactoryGirl.build(:assignment, :store => @CMUStore, :employee => @employee)
      assert !bad_assignment.valid?
      @employee.destroy
    end


  end
end
