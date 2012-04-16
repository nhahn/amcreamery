require 'test_helper'

class StoreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  # Check relationships
  should have_many(:employees).through(:assignments)
  should have_many(:assignments)

  # Validation macros
  should validate_presence_of(:name)
  should validate_presence_of(:street)
  should validate_presence_of(:city)
  # -------------------------------
  # Test scopes and other methods

  context "Three stores, with five employees, each with an assignment to that store" do

    setup do
      @CMUStore = FactoryGirl.create(:store)
      @ShadyStore = FactoryGirl.create(:store, :name=> "Shadyside", :street => "300 Negley Ave", :zip => "15218")
      @OaklandStore = FactoryGirl.create(:store, :name=> "Oakland", :street => "200 5th Ave", :zip => "15222", :phone => "(123) 456-7890")
      @InactiveStore = FactoryGirl.create(:store, :name=> "Inactive", :active => false)

      @CMUManager = FactoryGirl.create(:employee, :role => "admin")
      @CMUEmployee = FactoryGirl.create(:employee, :first_name => "Jim", :last_name => "Jones", :date_of_birth => 15.years.ago)

      @ShadyManager = FactoryGirl.create(:employee, :role => "manager", :first_name => "Shady", :last_name => "Guy", :date_of_birth => 30.years.ago)

      @OaklandManager = FactoryGirl.create(:employee, :role => "admin", :first_name => "Joe", :last_name => "White", :date_of_birth => 40.years.ago)
      @OaklandEmployee = FactoryGirl.create(:employee, :first_name => "Tyler", :last_name => "Mansfield", :date_of_birth => 17.years.ago)

      @CMUManagerAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUManager)
      @CMUEmployeeAssignment = FactoryGirl.create(:assignment, :store => @CMUStore, :employee => @CMUEmployee, :start_date =>5.days.ago)

      @ShadyManagerAssignment = FactoryGirl.create(:assignment, :store => @ShadyStore, :employee => @ShadyManager, :start_date => 1.year.ago)

      @OaklandManagerAssignment = FactoryGirl.create(:assignment, :store => @OaklandStore, :employee => @OaklandManager, :start_date => 2.years.ago)
      @OaklandEmployeeAssignment = FactoryGirl.create(:assignment, :store => @OaklandStore, :employee => @OaklandEmployee, :start_date => 4.months.ago)

    end

    teardown do
      @CMUStore.destroy
      @ShadyStore.destroy
      @OaklandStore.destroy
      @InactiveStore.destroy
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
  
    #test search scope
    should "find a store by name" do
      assert_equal "15232", Store.search("Shadyside").first.zip
    end
    
    #test that phone characters are removed
    should "tests for phone character being removed" do
      assert_equal "1234567890", Store.search("Oakland").first.phone
    end

    #test for uniqueness validation
    should "not allow store with the same name" do
      @store = FactoryGirl.build(:store, :name => "Oakland")
      assert !@store.valid?
    end

    #test alphabetical scope
    should "have all stores ordered alphabetically" do
      assert_equal 4, Store.all.size
      assert_equal ["CMU", "Inactive", "Oakland", "Shadyside"], Store.alphabetical.map{ |s| s.name}
    end

    #test active scope
    should "have all active stores accounted for" do
      assert_equal 3, Store.active.size
    end

    #test inactive scope
    should "have all inactive stores accounted for" do
      assert_equal 1, Store.inactive.size
    end

    #test employee relationships
    should "have all employees for a partcular store" do
      assert_equal ["John", "Jim"], @CMUStore.employees.map{ |e| e.first_name}
    end

    should "return a map" do
      assert !@CMUStore.create_map_link.nil?
    end

  end

end
