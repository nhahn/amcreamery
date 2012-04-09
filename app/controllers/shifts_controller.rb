class ShiftsController < ApplicationController
  # GET /shifts
  # GET /shifts.json

  authorize_resource


  INDEX_SORT = SortIndex::Config.new(
    {'date' => 'date'},
    {   
        'time' => 'start_time',
        'name' => 'UPPER(first_name), UPPER(last_name)',
    }   
  )
  
  def index
    @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
    @shifts = Shift.joins(:assignment).joins(:employee).paginate(:page => params[:page]).order(@sortable.order).per_page(15)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shifts }
    end
  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
    @shift = Shift.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shift }
    end
  end

  # GET /shifts/new
  # GET /shifts/new.json
  def new
    @shift = Shift.new
    @shift.assignment_id = params[:id] unless params[:id].nil?

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shift }
    end
  end

  # GET /shifts/1/edit
  def edit
    @shift = Shift.find(params[:id])
  end

  # POST /shifts
  # POST /shifts.json
  def create
    assignment =  Assignment.current.for_employee(Employee.find(params[:shift][:employee]))
    params[:shift].delete(:employee)
    @shift = Shift.new(params[:shift])
    @shift.assignment_id = assignment

    respond_to do |format|
      if @shift.save
        format.html { redirect_to @shift, notice: 'Shift was successfully created.' }
        format.json { render json: @shift, status: :created, location: @shift }
      else
        format.html { render action: "new" }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shifts/1
  # PUT /shifts/1.json
  def update
    @shift = Shift.find(params[:id])

    respond_to do |format|
      if @shift.update_attributes(params[:shift])
        format.html { redirect_to @shift, notice: 'Shift was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
    @shift = Shift.find(params[:id])
    @shift.destroy

    respond_to do |format|
      format.html { redirect_to shifts_url }
      format.json { head :no_content }
    end
  end
end
