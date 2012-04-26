class UsersController < ApplicationController

  def new
    @user = User.new
    @employee = Employee.find_by_id(session[:employee])
  end

  def employeeSearch
    @employee = Employee.new 
  end

  def lookupEmployee
    employee = Employee.find_by_ssn(params[:employee][:email].gsub("-","").chomp)
    if (!employee.nil? && employee.date_of_birth == Chronic.parse(params[:employee][:date_of_birth]).to_date)
      session[:employee] = employee.id
      redirect_to new_user_path
    else
      flash[:error] = "Could not find employee"
      render :action => 'employeeSearch'
    end
  end

  def create
    @user = User.new(params[:user])
    @user.employee_id = session[:employee]
    if @user.save
      session[:user_id] = @user.id
      EmployeeMailer.login_msg(@user, params[:user][:password]).deliver
      redirect_to home_url, :notice => "Thank you for signing up! You are now logged in."
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to home_url, :notice => "Your profile has been updated."
    else
      render :action => 'edit'
    end
  end
end
