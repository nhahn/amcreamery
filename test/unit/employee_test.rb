require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  # Check relationships
  should have_many(:assignments)
  should have_many(:stores).through(:assignments)
  should have_one(:user)

  # Validation Macros
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  should validate_presence_of(:date_of_birth)
  should validate_presence_of(:role)
  should validate_presence_of(:ssn)

  # Check the role regex
  should_not allow_value("killer").for(:role)

  #Check the SSN regex
  should_not allow_value("444").for(:ssn)
  should_not allow_value("555-555.5555").for(:ssn)
  
  # Check the phone regex
  should_not allow_value("703123").for(:phone)
  should_not allow_value("703-22-3456").for(:phone)
  should_not allow_value("703.333!3456").for(:phone)

  # Check the validates_date for date_of_birth
  should_not allow_value(Date.current + 1).for(:date_of_birth)
  should_not allow_value(12.years.ago).for(:date_of_birth)
  should_not allow_value("not a date").for(:date_of_birth)
  should  allow_value(15.years.ago).for(:date_of_birth)

  # -------------------------
  # Test scope and other methods

  context "Three stores, with five employees, each with an assignment to that store" do
    setup do
      @CMUStore = FactoryGirl.create(:store)
      @ShadyStore = FactoryGirl.create(:store, :name=> "Shadyside", :street => "300 Negley Ave", :zip => "15218")
      @OaklandStore = FactoryGirl.create(:store, :name=> "Oakland", :street => "200 5th Ave", :zip => "15222")

      @CMUManager = FactoryGirl.create(:employee, :role => "admin", :phone => "(703)-272-8443")
      @CMUEmployee = FactoryGirl.create(:employee, :first_name => "Jim", :last_name => "Jones", :ssn => "123456789", :date_of_birth => 15.years.ago)

      @ShadyManager = FactoryGirl.create(:employee, :role => "manager", :first_name => "Shady", :last_name => "Guy", :date_of_birth => 30.years.ago)

      @OaklandManager = FactoryGirl.create(:employee, :role => "admin", :first_name => "Joe", :last_name => "White", :date_of_birth => 40.years.ago)
      @OaklandEmployee = FactoryGirl.create(:employee, :first_name => "Tyler", :last_name => "Mansfield", :date_of_birth => 16.years.ago, :active => false)

      @CMUManagerAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUManager)
      @CMUEmployeeAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUEmployee, :start_date =>5.days.ago)

      @ShadyManagerAssignment = FactoryGirl.create(:assignment, :store => @ShadyStore, :employee => @ShadyManager, :start_date => 1.year.ago)

      @OaklandManagerAssignment = FactoryGirl.create(:assignment, :store => @OaklandStore, :employee => @OaklandManager, :start_date => 2.years.ago)

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
    end

    should "find the employee with the first name Jim" do
      assert_equal Employee.search("Jim").map{|e| e.first_name + " " + e.last_name}, ["Jim Jones"]
    end
  
    should "find the employee with the last name Guy" do
      assert_equal Employee.search("Guy").map{|e| e.first_name + " " + e.last_name}, ["Shady Guy"]
    end

    should "remove dashes from ssn" do
      assert_equal Employee.search("Jim").first.ssn, "123456789"
    end
    
    should "remove character from phone number" do
      assert_equal Employee.search("John").first.phone, "7032728443"
    end

    should "give the proper name for an employee" do
      assert_equal @CMUEmployee.proper_name, "Jim Jones"
    end

    should "give the name for an employee" do
      assert_equal @CMUEmployee.name, "Jones, Jim"
    end
    
    should "return the age of an employee" do
      assert_equal "30", @ShadyManager.age.to_s
    end

    should "return the current asssignment of an employee" do
      assert @CMUManager.current_assignment
    end

    should "return nil if no current assignment is there for an employee" do
      @employee = FactoryGirl.build(:employee, :first_name => "Nathan", :last_name => "Hahn", :ssn => "123456789", :date_of_birth => 20.years.ago)
      assert !@employee.current_assignment
      @employee.destroy
    end

    should "return the employees in alphabetical order" do
      assert_equal ["Guy", "Jones", "Mansfield", "Smith", "White"], Employee.alphabetical.map{|e| e.last_name}
    end

    should "check if employees are younger than 18" do
      assert_equal false,  @OaklandEmployee.over_18?
      assert_equal true,  @OaklandManager.over_18?
    end

    should "return all employees younder than 18" do
      assert_equal ["Jones", "Mansfield"], Employee.younger_than_18.alphabetical.map{|e| e.last_name}

    end

    should "return all employees older than 18" do
      assert_equal ["Guy", "Smith", "White"], Employee.is_18_or_older.alphabetical.map{|e| e.last_name}
    end

    should "return the active employees" do
      assert_equal ["Guy", "Jones",  "Smith", "White"], Employee.active.alphabetical.map{|e| e.last_name}
    end

    should "return the inactive employee" do
      assert_equal "Mansfield", Employee.inactive.first.last_name
    end

    should "return managers" do
      assert_equal "Guy", Employee.managers.first.last_name
    end

    should "return admins" do
      assert_equal ["Smith", "White"], Employee.admins.alphabetical.map{|e| e.last_name}
    end

    should "return regular employees" do
      assert_equal ["Jones", "Mansfield"], Employee.regulars.alphabetical.map{|e| e.last_name}
    end

  end
end
