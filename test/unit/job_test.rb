require 'test_helper'

class JobTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  # Check relationships  
  should have_many(:shifts).through(:shift_jobs)
  
  # Validation macros
  should validate_presence_of(:name)
  
  context "Three stores, with five employees, each with an assignment to that store and a shift with jobs" do
    setup do
      @SweepJob = FactoryGirl.create(:job)
	    @DishJob = FactoryGirl.create(:job, :name => "Dishes", :description => "Do the dishes")
	    @InactiveJob = FactoryGirl.create(:job, :name => "Inactive", :active => false)
    end

    teardown do
      @SweepJob.destroy
	    @DishJob.destroy
    end
	
    should "not allow two jobs with the same name" do
      @job = FactoryGirl.build(:job)
      assert !@job.valid?
    end

    should "return all jobs in alphabetical order" do
      assert_equal ["Dishes", "Inactive", "Sweep"], Job.alphabetical.map{|j| j.name}
    end

    should "return all active jobs" do
      assert_equal ["Dishes", "Sweep"], Job.active.alphabetical.map{|j| j.name}
    end

    should "return the only inactive job" do
      assert_equal ["Inactive"], Job.inactive.alphabetical.map{|j| j.name}
    end

  end

end
