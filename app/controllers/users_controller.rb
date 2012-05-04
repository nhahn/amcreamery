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
    if (!employee.nil? && employee.date_of_birth == Chronic.parse(params[:employee][:date_of_birth]).to_date && !User.find_by_employee_id(employee.id).nil?)
      logger.info User.find_by_employee_id(employee.id).nil?
      render :action => 'employeeSearch', notice: "Account already exists for employee"
    elsif (!employee.nil? && employee.date_of_birth == Chronic.parse(params[:employee][:date_of_birth]).to_date)
      session[:employee] = employee.id
      redirect_to new_user_path
    else
      render :action => 'employeeSearch', notice: "Could not find employee"
    end
  end

  def create
    @user = User.new(params[:user])
    @user.employee_id = session[:employee]
    if @user.save
      EmployeeMailer.login_msg(@user, params[:user][:password]).deliver
      if session[:user_id].nil?
        session[:user_id] = @user.id
        redirect_to home_url, :notice => "Thank you for signing up! You are now logged in." 
      else
        redirect_to employees_path, :notice => "Employee has been signed up and notified"
      end
    else
      session[:employee] = @user.employee_id
      respond_to do |format|
        format.html { render :action => 'new'}
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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
