class HomeController < ApplicationController

  
  INDEX_SORT = SortIndex::Config.new(
    {'store' => 'name'},
    {   
        'store' => 'name', 
    }   
  )

  EMPLOYEE_SORT = SortIndex::Config.new(
    {'updated_at' => 'updated_at'},
    {   
        'age' => 'date_of_birth',
        'full_name' => 'UPPER(first_name), UPPER(last_name)',
    }   
  )

  def home
    if logged_in?
      if  current_user.employee.role == "admin"
        @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
        @stores = Store.paginate(:page => params[:page]).order(@sortable.order).per_page(10)
          
        if params[:start_date].nil?
          @date = Time.now
        else
          @date = Date.parse(params[:start_date])
        end
        @date = @date - (@date.wday==0 ? 6 : @date.wday-1).days
        @start_date = Date.new(@date.year, @date.month, @date.day)
        @events = Shift.where('date between ? and ?', @start_date, @start_date+7).chronological.to_a
        logger.debug @events.map{|event| event.start_time}

      elsif current_user.employee.role == "manager"

      elsif current_user.employee.role == "employee"

      end
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
