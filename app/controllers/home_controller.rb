class HomeController < ApplicationController

  INDEX_SORT = SortIndex::Config.new(
    {'store' => 'name'},
    {   
        'store' => 'name', 
    }   
  )

  def home
    if logged_in?
      if  current_user.employee.role == "admin"
        @sortable = SortIndex::Sortable.new(params, INDEX_SORT)
        @stores = Store.paginate(:page => params[:page]).order(@sortable.order).per_page(10)
         
        @date = Time.now
        @date = @date - (@date.wday==0 ? 6 : @date.wday-1).days
        @start_date = Date.new(@date.year, @date.month, @date.day)
        @events = Shift.where('date between ? and ?', @start_date, @start_date+7).to_a


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

end
