require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  # -------------------------
  # Test scope and other methods

  def new_user(attributes = {}) 
    attributes[:email] ||= 'foo@example.com'
    attributes[:password] ||= 'abc123'
    attributes[:password_confirmation] ||= attributes[:password]
    user = User.new(attributes)
    user.valid? # run validations
    user
  end 

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
      @adminUser = new_user(:email => 'admin@example.com', :employee_id => @CMUManager.id)   
      @managerUser = new_user(:email => 'manager@example.com', :employee_id => @ShadyManager.id)   
      @employeeUser = new_user(:email => 'employee@example.com', :employee_id => @OaklandEmployee.id)   
     
      @adminAbility = Ability.new(@adminUser)
      @managerAbility = Ability.new(@managerUser)
      @employeeAbility = Ability.new(@employeeUser)
      @anyoneAbility = Ability.new(nil) 
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
   
   should "allow admins to do whatever they want" do
      assert @adminAbility.can?(:manage, :all)
   end
   should "allow manager certain powers" do
      assert @managerAbility.can?(:create, Job)
      assert @managerAbility.can?(:read, Job)
      assert @managerAbility.can?(:update, Job)
      assert @managerAbility.can?(:read, Store)
      assert @managerAbility.can?(:update, @ShadyManager.current_assignment.store)
      assert @managerAbility.can?(:show, @ShadyManager)
      assert @managerAbility.can?(:update, @ShadyManager)
   end
   should "allow employees certain powers" do
      assert @employeeAbility.can?(:update, @employeeUser)
      assert @employeeAbility.can?(:read, @OaklandEmployee)
      assert @employeeAbility.can?(:read, Store)
   end  
   should "allow anyone to make an account and view stores" do
      assert @anyoneAbility.can?(:read, Store)
      assert @anyoneAbility.can?(:create, User)
   end
  end
end
