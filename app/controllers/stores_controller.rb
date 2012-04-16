class StoresController < ApplicationController
  # GET /stores
  # GET /stores.json

  INDEX_SORT = SortIndex::Config.new(
    {'name' => 'name'},
    {
        'name' => 'name',
        'city' => 'city'
    }
  )

  EMPLOYEE_SORT = SortIndex::Config.new(
    {'updated_at' => 'updated_at'},
    {   
        'age' => 'date_of_birth',
        'full_name' => 'UPPER(first_name), UPPER(last_name)',
    }   
  )
  
  authorize_resource

  def index
    @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
    @stores = Store.paginate(:page => params[:page]).order(@sortable.order).per_page(10)
    markers, i = "", 1
    Store.order(@sortable.order).each do |str|
      markers += "&markers=color:red%red7Ccolor:red%7Clabel:#{i}%7C#{str.latitude},#{str.longitude}"
      i += 1
    end 
    @image = "http://maps.google.com/maps/api/staticmap?center=&size=400x400&maptype=roadmap#{markers}&sensor=false"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stores }
    end
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
    @store = Store.find(params[:id])
    @upcomingShifts = @store.shifts.upcomming.chronological

    @employeeSort = SortIndex::Sortable.new(params, EMPLOYEE_SORT)
    @employees = Employee.joins(:stores).where('store_id = ?', @store.id).paginate(:page => params[:page]).order(@employeeSort.order).per_page(7)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @store }
    end
  end

  # GET /stores/new
  # GET /stores/new.json
  def new
    @store = Store.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @store }
    end
  end

  # GET /stores/1/edit
  def edit
    @store = Store.find(params[:id])
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(params[:store])

    respond_to do |format|
      if @store.save
        format.html { redirect_to @store, notice: 'Store was successfully created.' }
        format.json { render json: @store, status: :created, location: @store }
      else
        format.html { render action: "new" }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stores/1
  # PUT /stores/1.json
  def update
    @store = Store.find(params[:id])

    respond_to do |format|
      if @store.update_attributes(params[:store])
        format.html { redirect_to @store, notice: 'Store was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store = Store.find(params[:id])
    # We don't want to delete, just deactivate
    if (@store.shifts.empty?)
      @store.destroy
    else
      @store.update_attributes("active" => false)
      @store.save!
    end 

    respond_to do |format|
      format.html { redirect_to stores_url }
      format.json { head :no_content }
    end
  end
end
