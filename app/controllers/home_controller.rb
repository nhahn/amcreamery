class HomeController < ApplicationController

  
  INDEX_SORT = SortIndex::Config.new(
    {'store' => 'name'},
    {   
        'store' => 'name', 
         'city' => 'city'
    }   
  )

  EMPLOYEE_SORT = SortIndex::Config.new(
    {'name' => 'UPPER(first_name), UPPER(last_name)'},
    {   
        'age' => 'date_of_birth',
        'full_name' => 'UPPER(first_name), UPPER(last_name)',
    }   
  )

  def home
    if logged_in?
      if params[:start_date].nil?
          @date = Time.now
        else
          @date = Date.parse(params[:start_date])
        end
        @date = @date - (@date.wday==0 ? 6 : @date.wday-1).days
        @start_date = Date.new(@date.year, @date.month, @date.day)
      if  current_user.employee.role == "admin"
        @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
        @stores = Store.paginate(:page => params[:page]).order(@sortable.order).per_page(10)
        @hours = Employee.all.collect{|emp| {:emp => emp, :hours => emp.shifts.inject(0){|sum, n| (n.date >= Date.parse(2.week.ago.to_s))? sum + n.hours : sum += 0}}}.sort{|a,b| [b[:hours], a[:emp].last_name] <=> [a[:hours], b[:emp].last_name]}.first(5)
        @events = Shift.where('date between ? and ?', @start_date, @start_date+7).chronological.to_a        

      elsif current_user.employee.role == "manager"

        store = current_user.employee.current_assignment.store
        @sortable = SortIndex::Sortable.new(params, EMPLOYEE_SORT)
        @employee = Assignment.current.for_store(store.id).joins(:employee).paginate(:page => params[:page]).per_page(7).order(@sortable.order)
        @employeeHours = Hash.new
        @employee.each do |employee|
        @employeeHours[employee.id] = employee.shifts.inject(0){|sum, n| (n.date >= Date.parse(2.week.ago.to_s))? sum + n.hours : sum += 0}
        end
        @pastShift = Shift.past.map{|shift| shift unless shift.completed?}.compact

        @events = Shift.joins(:assignment).where('end_date is NULL').where('store_id = ?', store.id).where('date > ? and date <= ?', @start_date, @start_date+7).chronological.to_a
        @incomplete = Shift.past.chronological.map{|shift| shift if shift.shift_jobs.empty?}.compact.first(9)
      
      elsif current_user.employee.role == "employee"

        @employee = current_user.employee
        @events = Shift.joins(:assignment).where('employee_id = ?', current_user.employee.id).where('date > ? and date <= ?', @start_date, @start_date+7).chronological.to_a

      end
    else
      @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
      @stores = Store.paginate(:page => params[:page]).order(@sortable.order).per_page(5)

      markers, i = "", 1
      Store.order(@sortable.order).each do |str|
        markers += "&markers=color:red%red7Ccolor:red%7Clabel:#{i}%7C#{str.latitude},#{str.longitude}"
        i += 1
      end 
      @image = "http://maps.google.com/maps/api/staticmap?center=&size=400x400&maptype=roadmap#{markers}&sensor=false"
    end
  end

  def about
  end

  def privacy
  end

  def contact
  end

  def search
    @EmployeeSortable = SortIndex::Sortable.new(params, EMPLOYEE_SORT)
    searchParams = params[:query]

    @employees = Employee.search(searchParams).paginate(:page => params[:page]).order(@EmployeeSortable.order).per_page(10)

  end

end
