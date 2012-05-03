class EmployeesController < ApplicationController
  # GET /employees
  # GET /employees.json

  authorize_resource

  INDEX_SORT = SortIndex::Config.new(
    {'updated_at' => 'updated_at'},
    {
        'age' => 'date_of_birth',
        'full_name' => 'UPPER(first_name), UPPER(last_name)',
    }
  )
  
  def index
    @inactive = (params[:inactive] == "true")?true:false
    @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
    if @inactive
      @employees = Employee.inactive.paginate(:page => params[:page]).order(@sortable.order).per_page(15)
    else
      @employees = Employee.active.paginate(:page => params[:page]).order(@sortable.order).per_page(15)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @employees }
    end
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
    @employee = Employee.find(params[:id])
    @upcomingShifts = @employee.shifts.upcomming.chronological
    @assignments = @employee.assignments.sort{|x,y| y.start_date <=> x.start_date}

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @employee }
    end
  end

  # GET /employees/new
  # GET /employees/new.json
  def new
    @employee = Employee.new
    @assignment = Assignment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @employee }
    end
  end

  # GET /employees/1/edit
  def edit
    @employee = Employee.find(params[:id])
  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(params[:employee])
    @employee.date_of_birth = Chronic.parse(params[:employee][:date_of_birth])
    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render json: @employee, status: :created, location: @employee }
      else
        format.html { render action: "new" }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /employees/1
  # PUT /employees/1.json
  def update
    @employee = Employee.find(params[:id])
    @employee.attributes = params[:id]
    @employee.date_of_birth = Chronic.parse(params[:employee][:date_of_birth])
    
    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.json
  def destroy
    @employee = Employee.find(params[:id])
    @employee.active = false
    @employee.save
    respond_to do |format|
      format.html { redirect_to employees_url }
      format.json { head :no_content }
    end
  end

  def load_employee
    render :partial => "/employees/details", :locals => {:employee => Employee.find(params[:id])}
  end

  def autocompleteAsn
    employees = Employee.search(params[:term])
    hash = Hash.new
    employees.each do |employee|
      hash[employee.proper_name] = employee.current_assignment.id unless employee.current_assignment.nil?
    end

    render :json => hash.collect{|key, value| {:value => value, :label => "#{key}"}}
  end

  def autocompleteEmp
    render :json => Employee.search(params[:term]).collect{|value| {:value => value.id, :label => "#{value.proper_name}"}}
  end

  def import
  end

  require 'csv'
  def parseCSV
    n = 0
    CSV.foreach(params[:file][:csv].tempfile, :headers => true) do |row|
      emp = Employee.new
      user = nil
      row.to_hash.each do |key, value|
        case key.downcase.gsub(/\s+/,"")
        when "name", "fullname"
          if value.include? ','
            split = value.chomp.split(',')
            emp.first_name = split[1].chomp
            emp.last_name = split[0].chomp
          else
            split = value.chomp.split(' ')
            emp.first_name = split[0].chomp
            emp.last_name = split[1].chomp
          end
        when "firstname", "first"
          emp.first_name = value.chomp
        when "lastname", "last"
          emp.last_name = value.chomp
        when "role", "position", "type"
          emp.role = value.downcase.chomp
        when "ssn", "socialsecuritynumber"
          emp.ssn = value.chomp
        when "dateofbirth", "birthday", "dob"
          emp.date_of_birth = Chronic.parse(value)
        when "phone", "phonenumber", "phone#"
          emp.phone = value.chomp
        when "email", "emailaddress"
          user = User.new
          user.email = value.chomp
          user.password = SecureRandom.hex(10)
          user.password_confirmation = user.password
        end
      end
      if emp.save
        n += 1
      end
      if user
        user.employee_id = emp.id
        if user.save
          EmployeeMailer.login_msg(user, user.password).deliver
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to employees_url, notice: "CVS Import Sucessful, #{n} new records added." }
      format.json { head :no_content }
    end
  end

end
