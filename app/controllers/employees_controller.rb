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
    @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
    @employees = Employee.paginate(:page => params[:page]).order(@sortable.order).per_page(15)

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

    @date = Time.now
    @date = @date - (@date.wday==0 ? 6 : @date.wday-1).days
    @start_date = Date.new(@date.year, @date.month, @date.day)
    @events = @employee.shifts.where('date between ? and ?', @start_date, @start_date+7).to_a

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

    respond_to do |format|
      if @employee.update_attributes(params[:employee])
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

end
