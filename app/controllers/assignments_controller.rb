class AssignmentsController < ApplicationController
  # GET /assignments
  # GET /assignments.json

  authorize_resource

  INDEX_SORT = SortIndex::Config.new(
    {'name' => 'UPPER(first_name), UPPER(last_name)'},
    {   
        'employee' => 'UPPER(first_name), UPPER(last_name)',
        'store' => 'name',
        'pay' => 'pay_level'
    }   
  ) 

  def index
    @past = (params[:past] == "true")?true:false
    @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
    
    if @past
      @assignments = Assignment.joins(:employee).joins(:store).past.paginate(:page => params[:page]).order(@sortable.order).per_page(15)
    else
      @assignments = Assignment.joins(:employee).joins(:store).current.paginate(:page => params[:page]).order(@sortable.order).per_page(15)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assignments }
    end
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
    @assignment = Assignment.find(params[:id])
    if params[:start_date].nil?
      @date = Time.now
    else
      @date = Date.parse(params[:start_date])
    end 
    @date = @date - (@date.wday==0 ? 6 : @date.wday-1).days
    @start_date = Date.new(@date.year, @date.month, @date.day)
    @events = Shift.joins{:assignment}.where('assignment_id = ?',@assignment.id).where('date between ? and ?', @start_date, @start_date+7).chronological.to_a    


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assignment }
    end
  end

  # GET /assignments/new
  # GET /assignments/new.json
  def new
    @assignment = Assignment.new
    @assignment.store_id = params[:id] unless params[:id].nil?
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assignment }
    end
  end

  # GET /assignments/1/edit
  def edit
    @assignment = Assignment.find(params[:id])
  end

  # POST /assignments
  # POST /assignments.json
  def create
    params[:assignment].delete(:employee)
    @assignment = Assignment.new(params[:assignment])
    @assignment.start_date = Chronic.parse(params[:assignment][:start_date])
    @assignment.end_date = Chronic.parse(params[:assignment][:end_date])

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
        format.json { render json: @assignment, status: :created, location: @assignment }
      else
        format.html { render action: "new" }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assignments/1
  # PUT /assignments/1.json
  def update
    params[:shift].delete(:employee)
    @assignment = Assignment.find(params[:id])
    @assignment.attributes = params[:assignment]
    @assignment.start_date = Chronic.parse(params[:assignment][:start_date])
    @assignment.end_date = Chronic.parse(params[:assignment][:end_date])

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to assignments_url }
      format.json { head :no_content }
    end
  end
end
